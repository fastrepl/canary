defmodule Canary.Interactions.Discord.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Channel

  @channel_text 0
  @channel_public_thread 11

  def handle_event({:MESSAGE_CREATE, %{author: %{bot: true}}, _ws_state}) do
    :ignore
  end

  def handle_event({:MESSAGE_CREATE, user_msg, _ws_state}) do
    channel = Api.get_channel!(user_msg.channel_id)
    handle_message(channel, user_msg)
  end

  def handle_event({:THREAD_CREATE, channel, _ws_state}) do
    :ignore
  end

  defp handle_message(
         %Channel{type: @channel_public_thread, id: channel_id, guild_id: guild_id} = channel,
         %Message{} = user_msg
       ) do
    :ignore
  end

  defp handle_message(%Channel{type: @channel_text}, _user_msg), do: :ignore
  defp handle_message(_, _), do: :ignore
end
