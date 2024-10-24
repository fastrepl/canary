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
    {:ok, results} = Trieve.client(project) |> Trieve.search(query, opts)

    {:ok, pid} = Agent.start_link(fn -> "" end)

    {:ok, completion} =
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
              content: Jason.encode!(%{query: query, docs: results})
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
              safe(handle_delta, {:delta, content})
              Agent.update(pid, &(&1 <> content))

            _ ->
              :ok
          end
        end
      )

    completion = if completion == "", do: Agent.get(pid, & &1), else: completion
    safe(handle_delta, {:done, completion})

    {:ok, %{response: completion}}
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end
end
