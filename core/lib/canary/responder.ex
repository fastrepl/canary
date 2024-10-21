defmodule Canary.Responder do
  @callback run(any(), String.t(), function(), keyword()) :: {:ok, any()} | {:error, any()}

  alias Canary.Responder

  def run(project, query, handle_delta, opts \\ []) do
    impl().run(project, query, handle_delta, opts)
  end

  defp impl, do: Application.get_env(:canary, :responder, Responder.Default)
end

defmodule Canary.Responder.Default do
  @behaviour Canary.Responder

  require Logger
  require Ash.Query

  def run(project, query, handle_delta, opts) do
    {:ok, results} = Canary.Searcher.run(project, query, opts)

    docs =
      results
      |> search_results_to_docs()
      |> Enum.take(5)

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
          model: Application.fetch_env!(:canary, :responder_model),
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
    results
    |> Enum.map(fn result ->
      %{
        url: result.url,
        title: result.title,
        content: result.sub_results |> Enum.map(& &1.excerpt) |> Enum.join("\n")
      }
    end)
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end
end
