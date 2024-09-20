defmodule Canary.Interactions.Responder do
  alias Canary.Interactions.Responder

  @callback run(
              sources :: list(any()),
              query :: String.t(),
              handle_delta :: function(),
              opts :: keyword()
            ) :: {:ok, any()} | {:error, any()}

  def run(sources, query, handle_delta, opts \\ []) do
    impl().run(sources, query, handle_delta, opts)
  end

  defp impl, do: Application.get_env(:canary, :responder, Responder.Default)
end

defmodule Canary.Interactions.Responder.Default do
  @behaviour Canary.Interactions.Responder
  require Ash.Query

  def run(sources, query, handle_delta, opts) do
    {:ok, results} = Canary.Searcher.run(sources, query, cache: opts[:cache])

    docs =
      results
      |> search_results_to_docs()
      |> then(
        &Canary.Reranker.run!(query, &1, threshold: 0.05, renderer: fn doc -> doc.content end)
      )

    messages = [
      %{
        role: "system",
        content: Canary.Prompt.format("responder_system", %{})
      },
      %{
        role: "user",
        content: Canary.Prompt.format("responder_user", %{query: query, docs: docs})
      }
    ]

    {:ok, pid} = Agent.start_link(fn -> "" end)

    {:ok, completion} =
      Canary.AI.chat(
        %{
          model: Application.fetch_env!(:canary, :chat_completion_model),
          messages: messages,
          temperature: 0.2,
          frequency_penalty: 0.02,
          max_tokens: 5000,
          stream: handle_delta != nil
        },
        callback: fn data ->
          case data do
            %{"choices" => [%{"finish_reason" => reason}]}
            when reason in ["stop", "length", "eos"] ->
              :ok

            %{"choices" => [%{"delta" => %{"content" => content}}]} ->
              safe(handle_delta, %{type: :progress, content: content})
              Agent.update(pid, &(&1 <> content))
          end
        end
      )

    completion = if completion == "", do: Agent.get(pid, & &1), else: completion
    safe(handle_delta, %{type: :complete, content: completion})

    {:ok, %{response: completion, references: []}}
  end

  defp search_results_to_docs(results) do
    doc_ids =
      results
      |> Enum.flat_map(fn result -> Enum.map(result.sub_results, & &1.document_id) end)
      |> Enum.uniq()

    Canary.Sources.Document
    |> Ash.Query.filter(id in ^doc_ids)
    |> Ash.read!()
    |> Enum.flat_map(fn %{chunks: chunks} -> chunks end)
    |> Enum.map(fn chunk -> %{title: chunk.value.title, content: chunk.value.content} end)
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end
end
