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
        history: _history,
        handle_message: _handle_message,
        handle_message_delta: _handle_message_delta
      }) do
  end
end
