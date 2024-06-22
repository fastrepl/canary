defmodule Canary.Clients.Discord do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Channel

  @bot_name "Canary"
  @pending_message "working on it! (will ping you when it's done)"
  @failed_message "sorry, seems like we're having some problem"
  @timeout 60 * 1000

  @channel_text 0
  @channel_public_thread 11

  def handle_event({:MESSAGE_CREATE, user_msg, _ws_state}) do
    if mention?(user_msg) do
      channel = Api.get_channel!(user_msg.channel_id)
      handle_message(channel, user_msg)
    end
  end

  defp handle_message(%Channel{type: @channel_text, id: channel_id}, user_msg) do
    thread_name = user_msg.content |> strip() |> String.slice(0..20)

    {:ok, channel} =
      Api.start_thread_with_message(
        channel_id,
        user_msg.id,
        %{name: thread_name}
      )

    handle_message(channel, user_msg)
  end

  defp handle_message(%Channel{type: @channel_public_thread, id: channel_id}, user_msg) do
    {:ok, canary_msg} = Api.create_message(channel_id, content: @pending_message)
    respond(channel_id, user_msg.author.id, canary_msg.id, strip(user_msg.content))
  end

  defp handle_message(_, _), do: :ignore

  defp respond(channel_id, user_id, message_id, _query) do
    # {:ok, pid} = Canary.Sessions.find_or_start_session(channel_id)
    # GenServer.call(pid, {:submit, :website, %{query: query}})

    receive do
      {:complete, data} ->
        Api.delete_message(channel_id, message_id)
        Api.create_message(channel_id, content: "#{mention(user_id)}\n\n#{data}'")

      _ ->
        :ignore
    after
      @timeout ->
        Api.delete_message(channel_id, message_id)
        Api.create_message(channel_id, content: "#{mention(user_id)}\n\n#{@failed_message}'")
    end
  end

  defp strip(s), do: s |> String.replace(~r/<@!?\d+>/, "") |> String.trim()

  defp mention(id), do: "<@#{id}>"

  defp mention?(%Message{mentions: mentions}) do
    mentions |> Enum.any?(&(&1.bot && &1.username == @bot_name))
  end
end
