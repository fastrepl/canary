defmodule Canary.Interface.Ask do
  @callback run(any(), String.t(), function(), keyword()) :: {:ok, map()} | {:error, any()}

  def run(project, query, handle_delta, opts \\ []) do
    impl().run(project, query, handle_delta, opts)
  end

  defp impl(), do: Application.get_env(:canary, :interface_ask, Canary.Interface.Ask.Default)
end

defmodule Canary.Interface.Ask.Default do
  @behaviour Canary.Interface.Ask

  alias Canary.Index.Trieve

  def run(project, query, handle_delta, opts) do
    client = Trieve.client(project)
    opts = opts |> Keyword.put(:rag, true)

    {:ok, groups} = client |> Trieve.search(query, opts)

    results =
      groups
      |> Enum.take(5)
      |> Enum.map(fn %{"chunks" => chunks, "group" => %{"tracking_id" => group_id}} ->
        Task.async(fn ->
          chunk_indices =
            chunks |> Enum.map(&get_in(&1, ["chunk", "metadata", Access.key("index", 0)]))

          case Trieve.get_chunks(client, group_id, chunk_indices: chunk_indices) do
            {:ok, %{"chunks" => full_chunks}} ->
              full_chunks
              |> Enum.map(fn chunk ->
                %{
                  "url" => chunk["link"],
                  "content" => chunk["chunk_html"],
                  "metadata" => chunk["metadata"]
                }
              end)

            _ ->
              nil
          end
        end)
      end)
      |> Task.await_many(3_000)
      |> Enum.reject(&is_nil/1)

    {:ok, pid} = Agent.start_link(fn -> "" end)

    resp =
      Canary.AI.chat(
        %{
          model: Application.fetch_env!(:canary, :responder_model),
          messages: [
            %{
              role: "system",
              content: Canary.Prompt.format("responder_system", %{})
            },
            %{
              role: "user",
              content: """
              <retrieved_documents>
              #{Jason.encode!(results)}
              </retrieved_documents>

              <user_question>
              #{query}
              </user_question>
              """
            }
          ],
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
              safe(handle_delta, content)
              Agent.update(pid, &(&1 <> content))
          end
        end
      )

    with {:ok, completion} <- resp do
      completion = if completion == "", do: Agent.get(pid, & &1), else: completion
      {:ok, %{response: completion}}
    end
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end
end
