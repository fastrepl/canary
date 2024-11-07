defmodule CanaryWeb.StacksLive.Session do
  use CanaryWeb, :live_view

  alias Canary.Index.Trieve

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col max-w-4xl mx-auto h-screen pt-4">
      <h1 class="text-xl font-semibold mb-4">next-forge</h1>

      <div class="flex-grow overflow-y-auto flex flex-col gap-2">
        <div
          :for={{message, index} <- Enum.with_index(@messages)}
          class="flex flex-row gap-2 items-center"
        >
          <span class="text-gray-500"><%= message.role %></span>
          <div class="prose" id={"messsage-#{index}"} phx-hook="HighlightAll">
            <%= raw(Earmark.as_html!(message.content)) %>
          </div>
        </div>
      </div>

      <.form :let={f} for={@form} phx-change="validate" phx-submit="submit" class="relative mt-4">
        <.input
          id="session-form"
          phx-hook="EnterToSubmit"
          type="textarea"
          field={f[:message]}
          placeholder="Ask a question"
          class="h-32 w-full"
        />
        <.button type="submit" class="absolute right-2 bottom-2">↵</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, %{dataset_id: id}} = Cachex.get(:cache, id)

    socket =
      socket
      |> assign(:form, message_form())
      |> assign(:messages, [])
      |> assign(:client, Trieve.client(id))

    {:ok, socket}
  end

  defp message_form(params \\ %{}) do
    data = %{}
    types = %{message: :string}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message])
    |> Ecto.Changeset.validate_length(:message, min: 1)
    |> to_form(as: :form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = message_form(params)
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    messages =
      socket.assigns.messages ++
        [
          %{role: :user, content: params["message"]},
          %{role: :assistant, content: ""}
        ]

    here = self()
    client = socket.assigns.client

    socket =
      socket
      |> assign(:form, message_form())
      |> assign(:messages, messages)
      |> start_async(:generation, fn -> run(here, client, params["message"]) end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:delta, content}, socket) do
    messages =
      socket.assigns.messages
      |> update_in([Access.at(-1), :content], &(&1 <> content))

    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def handle_async(:generation, _d, socket) do
    {:noreply, socket}
  end

  defp run(here, client, query) do
    {:ok, groups} = client |> Trieve.search(query)

    results =
      groups
      |> Enum.take(8)
      |> Enum.map(fn %{"chunks" => chunks, "group" => %{"tracking_id" => group_id}} ->
        Task.async(fn ->
          chunk_indices =
            chunks |> Enum.map(&get_in(&1, ["chunk", "metadata", Access.key("index", 0)]))

          case Trieve.get_chunks(client, group_id, chunk_indices: chunk_indices) do
            {:ok, %{"chunks" => full_chunks}} ->
              full_chunks
              |> Enum.map(fn chunk ->
                %{
                  "url" => chunk["link"],
                  "content" => chunk["chunk_html"],
                  "metadata" => chunk["metadata"]
                }
              end)

            _ ->
              nil
          end
        end)
      end)
      |> Task.await_many(5_000)
      |> Enum.reject(&is_nil/1)

    Canary.AI.chat(
      %{
        model: "gpt-4o-mini",
        messages: [
          %{
            role: "user",
            content: """
            <retrieved_documents>
            #{Jason.encode!(results)}
            </retrieved_documents>

            <user_question>
            #{query}
            </user_question>
            """
          }
        ],
        temperature: 0,
        frequency_penalty: 0.02,
        max_tokens: 5000,
        stream: true
      },
      callback: fn data ->
        case data do
          %{"choices" => [%{"delta" => %{"content" => content}}]} ->
            send(here, {:delta, content})

          _ ->
            :ok
        end
      end
    )
  end
end
