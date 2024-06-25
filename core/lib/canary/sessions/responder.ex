defmodule Canary.Sessions.Responder do
  @type args :: %{
          history: list(),
          handle_message: function(),
          handle_message_delta: function()
        }

  @callback call(args()) :: any()

  def call(args), do: impl().call(args)
  defp impl, do: Application.get_env(:canary, :session_responder, Canary.Sessions.Responder.LLM)
end

defmodule Canary.Sessions.Responder.LLM do
  @behaviour Canary.Sessions.Responder

  def call(%{
        history: history,
        handle_message: handle_message,
        handle_message_delta: _handle_message_delta
      }) do
    model = Application.fetch_env!(:canary, :chat_completion_model)

    user_query = history |> List.last() |> Map.get(:content)
    {:ok, queries} = Canary.Query.Understander.run(user_query)
    query = queries |> List.first()

    docs =
      Canary.Sources.Document
      |> Ash.Query.for_read(:hybrid_search, %{text: query.text, embedding: query.embedding})
      |> Ash.read!()

    messages = [
      %{
        role: "user",
        content:
          "#{docs |> Enum.map(& &1.content) |> Enum.join("\n\n")}\n\nBased on the above retrieved documents, answer the user's question, within 3 sentences. User: #{user_query}"
      }
    ]

    {:ok, res} = Canary.AI.chat(%{model: model, messages: messages, stream: false})
    handle_message.(res)
  end
end
