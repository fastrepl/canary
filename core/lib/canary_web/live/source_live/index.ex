defmodule CanaryWeb.SourceLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <%= case @live_action do %>
        <% :index -> %>
          <.live_component
            id="source-index"
            module={CanaryWeb.SourceLive.List}
            sources={@sources}
            current_account={@current_account}
          />
        <% :detail -> %>
          <.live_component id="source-detail" module={CanaryWeb.SourceLive.Detail} source={@source} />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    sources =
      socket.assigns.current_account
      |> Ash.load!([:sources])
      |> Map.get(:sources)

    {:ok, socket |> assign(sources: sources)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :detail, %{"id" => id}) do
    case Enum.find(socket.assigns.sources, &(&1.id == id)) do
      nil -> socket |> redirect(to: ~p"/source")
      source -> socket |> assign(source: source)
    end
  end
end
