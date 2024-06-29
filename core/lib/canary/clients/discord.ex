defmodule Canary.Clients.Discord do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Channel

  require Ash.Query

  @bot_name "Canary"
  @no_source_message "we can't find any sources created for this channel."
  @failed_message "sorry, it seems like we're having some problems..."
  @timeout 30 * 1000

  @channel_text 0
  @channel_public_thread 11

  def handle_event({:MESSAGE_CREATE, %{author: %{username: @bot_name, bot: true}}, _ws_state}) do
    :ignore
  end

  def handle_event({:MESSAGE_CREATE, user_msg, _ws_state}) do
    if mention?(user_msg) do
      channel = Api.get_channel!(user_msg.channel_id)
      handle_message(channel, user_msg)
    end
  end

  defp handle_message(%Channel{type: @channel_text, id: channel_id, guild_id: guild_id}, user_msg) do
    if find_client(guild_id, channel_id) == nil do
      :ignore
    else
      thread_name = user_msg.content |> strip() |> String.slice(0..30)

      {:ok, channel} =
        Api.start_thread_with_message(channel_id, user_msg.id, %{name: thread_name})

      handle_message(channel, user_msg)
    end
  end

  defp handle_message(%Channel{type: @channel_public_thread} = channel, user_msg) do
    respond(channel, user_msg)
  end

  defp handle_message(_, _), do: :ignore

  defp respond(%Channel{id: thread_id, parent_id: channel_id, guild_id: guild_id}, user_msg) do
    client = find_client(guild_id, channel_id)
    source_ids = client.sources |> Enum.map(& &1.id)

    cond do
      length(source_ids) == 0 ->
        send_to_discord(thread_id, user_msg, @no_source_message)

      true ->
        Api.start_typing(thread_id)

        {:ok, session} =
          Canary.Sessions.find_or_create_session(
            client.account,
            {:discord, thread_id}
          )

        pid = self()

        Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
          {:ok, res} =
            Canary.Sessions.Responder.run(%{
              request: strip(user_msg.content),
              session: session,
              source_ids: source_ids
            })

          send(pid, {:complete, %{content: res}})
        end)

        receive_loop(thread_id, user_msg)
    end
  end

  defp receive_loop(thread_id, user_msg) do
    receive do
      {:complete, %{content: content}} ->
        send_to_discord(thread_id, user_msg, content)

      {:progress, _} ->
        IO.puts("progress")
        Api.start_typing(thread_id)
        receive_loop(thread_id, user_msg)
    after
      @timeout ->
        send_to_discord(thread_id, user_msg, @failed_message)
    end
  end

  defp send_to_discord(channel_id, user_msg, content) do
    user_id = user_msg.author.id
    msg_id = user_msg.id

    opts =
      if channel_id == user_msg.channel_id do
        [
          content: "#{mention(user_id)} #{content}",
          message_reference: %{message_id: msg_id}
        ]
      else
        [content: "#{mention(user_id)} #{content}"]
      end

    Api.create_message(channel_id, opts)
  end

  defp find_client(guild_id, channel_id) do
    args = %{
      discord_server_id: guild_id,
      discord_channel_id: channel_id
    }

    Canary.Clients.Client
    |> Ash.Query.for_read(:find_discord, args)
    |> Ash.read_one!()
  end

  defp strip(s) do
    s
    |> String.replace(~r/<@!?\d+>/, "")
    |> String.replace(~r/<#!?\d+>/, "")
    |> String.trim()
  end

  defp mention(id), do: "<@#{id}>"

  defp mention?(%Message{mentions: mentions}) do
    mentions |> Enum.any?(&(&1.bot && &1.username == @bot_name))
  end
end
