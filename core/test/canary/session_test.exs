defmodule Canary.Test.Session do
  use ExUnit.Case, async: false

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  test "it sends messages" do
    Canary.Sessions.Responder.Mock
    |> expect(:call, fn %{
                          handle_message: handle_message,
                          handle_message_delta: handle_message_delta
                        } ->
      handle_message_delta.("hi")
      handle_message_delta.(" and bye")
      handle_message.("hi and bye")
    end)

    {:ok, pid} = Canary.Sessions.find_or_start_session("TEST")
    :ok = GenServer.call(pid, {:submit, :website, %{query: "Hello!", source_ids: [1]}})

    assert_receive {:progress, %{content: "hi"}}
    assert_receive {:progress, %{content: " and bye"}}
    assert_receive {:complete, %{done: true}}
  end
end
