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

  alias Canary.Sources.Document

  def run(sources, query, handle_delta, opts) do
    {:ok, results} = Canary.Searcher.run(sources, query, cache: opts[:cache])

    docs =
      results
      |> search_results_to_docs()
      |> then(fn docs ->
        opts = [threshold: 0, renderer: fn doc -> doc.content end]
        Canary.Reranker.run!(query, docs, opts) |> Enum.take(5)
      end)

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
          temperature: 0,
          frequency_penalty: 0.02,
          max_tokens: 5000,
          response_format: %{type: "json_object"},
          stream: handle_delta != nil
        },
        callback: fn data ->
          case data do
            %{"choices" => [%{"finish_reason" => reason}]}
            when reason in ["stop", "length", "eos"] ->
              :ok

            %{"choices" => [%{"delta" => %{"content" => content}}]} ->
              safe(handle_delta, {:delta, content})
              Agent.update(pid, &(&1 <> content))

            _ ->
              :ok
          end
        end
      )

    completion = if completion == "", do: Agent.get(pid, & &1), else: completion
    safe(handle_delta, {:done, completion})

    {:ok, %{response: completion, references: [], docs: docs}}
  end

  defp search_results_to_docs(results) do
    doc_ids =
      results
      |> Enum.map(fn result -> result.document_id end)
      |> Enum.uniq()

    Canary.Sources.Document
    |> Ash.Query.filter(id in ^doc_ids)
    |> Ash.read!()
    |> Enum.sort_by(&Enum.find_index(doc_ids, fn id -> id == &1.id end))
    |> Enum.map(fn %Document{meta: %Ash.Union{value: meta}, chunks: chunks} ->
      %{
        url: meta.url,
        title: meta.title,
        content: chunks |> Enum.map(& &1.value.content) |> Enum.join("\n")
      }
    end)
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end
end
