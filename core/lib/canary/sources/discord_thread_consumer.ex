defmodule Canary.Sources.DiscordConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Channel

  @channel_text 0
  @channel_public_thread 11

  def handle_event({:MESSAGE_CREATE, %{author: %{bot: false}} = user_msg, _ws_state}) do
    channel = Api.get_channel!(user_msg.channel_id)
    handle_message(channel, user_msg)

    :ignore
  end

  def handle_event({:MESSAGE_UPDATE, %{author: %{bot: false}}, _ws_state}) do
    :ignore
  end

  def handle_event({:MESSAGE_DELETE, %{author: %{bot: false}}, _ws_state}) do
    :ignore
  end

  def handle_event({:MESSAGE_DELETE_BULK, %{author: %{bot: false}}, _ws_state}) do
    :ignore
  end

  def handle_event({:THREAD_CREATE, _channel, _ws_state}) do
    :ignore
  end

  def handle_event({:THREAD_UPDATE, _channel, _ws_state}) do
    :ignore
  end

  def handle_event({:THREAD_DELETE, _channel, _ws_state}) do
    :ignore
  end

  def handle_event({:INTEGRATION_CREATE, _event, _ws_state}) do
    :ignore
  end

  def handle_event({:INTEGRATION_DELETE, _event, _ws_state}) do
    :ignore
  end

  defp handle_message(
         %Channel{type: @channel_public_thread, id: _channel_id, guild_id: _guild_id} = _channel,
         %Message{} = _user_msg
       ) do
    :ignore
  end

  defp handle_message(%Channel{type: @channel_text}, _user_msg), do: :ignore
  defp handle_message(_, _), do: :ignore
end
