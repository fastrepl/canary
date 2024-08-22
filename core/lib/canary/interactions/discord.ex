defmodule Canary.Interactions.Discord do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Channel

  use Tracing
  require Ash.Query

  @bot_name "Canary"
  @timeout 30 * 1000
  @channel_text 0
  @channel_public_thread 11

  @no_source_message "we can't find any sources created for this channel."
  @failed_message "sorry, it seems like we're having some problems..."
  @rate_limit_message "you're sending too many requests. please try again in a few minutes."

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
    Tracing.span %{}, "discord" do
      respond(channel, user_msg)
    end
  end

  defp handle_message(_, _), do: :ignore

  defp respond(%Channel{id: thread_id, parent_id: channel_id, guild_id: guild_id}, user_msg) do
    client = find_client(guild_id, channel_id)
    source_ids = client.sources |> Enum.map(& &1.id)

    user_id = user_msg.author.id
    rate_limit = Hammer.check_rate("discord:#{user_id}", 60_000, 10)

    cond do
      length(source_ids) == 0 ->
        send_to_discord(thread_id, user_msg, @no_source_message)

      elem(rate_limit, 0) == :deny ->
        send_to_discord(thread_id, user_msg, @rate_limit_message)

      true ->
        Api.start_typing(thread_id)

        {:ok, session} =
          Canary.Interactions.find_or_create_session(
            client.account,
            {:discord, thread_id}
          )

        pid = self()
        ctx = Canary.Tracing.current_ctx()

        Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
          Canary.Tracing.attach_ctx(ctx)

          {:ok, res} =
            Canary.Interactions.Responder.run(session, "", strip(user_msg.content), client)

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
    Canary.Interactions.Client.find_discord!(guild_id, channel_id)
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
