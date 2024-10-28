defmodule CanaryWeb.ExampleLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(%{num_sources: 0} = assigns) do
    ~H"""
    <div>
      <%= render_header(assigns) %>

      <div class="w-full h-[calc(100vh-300px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
        <p class="text-lg">
          You don't have any sources yet.
        </p>
        <p>
          Head over to <.link navigate={~p"/source"}>sources</.link> tab to create your first source.
        </p>
      </div>
    </div>
    """
  end

  def render(%{num_total_documents: 0} = assigns) do
    ~H"""
    <div>
      <%= render_header(assigns) %>

      <div class="w-full h-[calc(100vh-300px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
        <p class="text-lg">
          You have some sources, but they don't have any documents yet.
        </p>
        <p>
          Head over to <.link navigate={~p"/source"}>sources</.link>
          tab and fetch documents from your sources.
        </p>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= render_header(assigns) %>
      <.live_component
        id="examples"
        module={CanaryWeb.ExampleLive.Examples}
        current_project={@current_project}
      />
    </div>
    """
  end

  defp render_header(assigns) do
    ~H"""
    <div class="mb-4">
      <h2>Examples</h2>
      <div>
        <div>
          For more information, please refer to our <a href="https://getcanary.dev">documentation</a>.
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_project =
      socket.assigns.current_project
      |> Ash.load!([:num_sources, sources: [:num_documents]])

    num_total_documents =
      current_project.sources
      |> Enum.reduce(0, fn source, acc -> acc + source.num_documents end)

    socket =
      socket
      |> assign(:current_project, current_project)
      |> assign(:num_sources, current_project.num_sources)
      |> assign(:num_total_documents, num_total_documents)

    {:ok, socket}
  end
end
