defmodule Canary.Interactions.Responder do
  alias Canary.Interactions.Responder

  @callback run(
              query :: String.t(),
              pattern :: String.t() | nil,
              client :: any(),
              handle_delta :: function()
            ) :: {:ok, any()} | {:error, any()}

  def run(query, pattern, client, handle_delta \\ nil) do
    impl().run(query, pattern, client, handle_delta)
  end

  defp impl, do: Application.get_env(:canary, :responder, Responder.Default)
end

defmodule Canary.Interactions.Responder.Default do
  @behaviour Canary.Interactions.Responder
  require Ash.Query

  def run(query, pattern, %{account: account, sources: sources}, handle_delta) do
    model = Application.fetch_env!(:canary, :chat_completion_model_response)
    source = sources |> Enum.at(0)
    {:ok, %{search: docs}} = Canary.Searcher.run(source, query)

    docs =
      if is_nil(pattern) do
        docs
      else
        docs
        |> Enum.filter(fn doc -> Canary.Native.glob_match(pattern, URI.parse(doc.url).path) end)
      end

    {:ok, pid} = Agent.start_link(fn -> "" end)

    {:ok, completion} =
      Canary.AI.chat(
        %{
          model: model,
          messages: [
            %{
              role: "system",
              content: Canary.Prompt.format("responder_system", %{})
            },
            %{
              role: "user",
              content: Canary.Prompt.format("responder_user", %{query: query, docs: docs})
            }
          ],
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

    references =
      completion
      |> parse_footnotes()
      |> Enum.map(fn i -> Enum.at(docs, i - 1) end)

    # TODO: there's great change this is invalid, and will cause problem to the client side.
    safe(handle_delta, %{type: :references, items: references})
    safe(handle_delta, %{type: :complete, content: completion})

    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Accounts.Billing.increment_ask(account.billing)
    end)

    {:ok, %{response: completion, references: references}}
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end

  def parse_footnotes(text) do
    regex = ~r/\[\^(\d+)\]:\s*(\d+)\s*$/m

    Regex.scan(regex, text)
    |> Enum.sort_by(fn [_, footnote_number, _] ->
      String.to_integer(footnote_number)
    end)
    |> Enum.map(fn [_, _, index] ->
      String.to_integer(index)
    end)
  end
end
