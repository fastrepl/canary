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
    {:ok, res} = Canary.AI.chat(%{model: model, messages: history, stream: false})
    handle_message.(res)
  end
end
