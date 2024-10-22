defmodule CanaryWeb.OnboardingLive.FirstSource do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <h2 class="mb-2">You haven't created any sources yet.</h2>

      <div>
        Head over to <.link navigate={~p"/source"}>sources</.link> tab to create your first source.
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end
end
