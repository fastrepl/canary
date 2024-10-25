defmodule CanaryWeb.ExampleLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(%{num_sources: 0} = assigns) do
    ~H"""
    <div>
      <div class="mb-4">
        <h2>Examples</h2>
        <div>
          <div>
            For more information, please refer to our <a href="https://getcanary.dev/docs">documentation</a>.
          </div>
        </div>
      </div>

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

  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-4">
        <h2>Examples</h2>
        <div>
          <div>
            For more information, please refer to our <a href="https://getcanary.dev/docs">documentation</a>.
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-4">
        <.live_component
          id="example-search"
          module={CanaryWeb.ExampleLive.Search}
          current_project={@current_project}
        />

        <.live_component
          id="example-ask"
          module={CanaryWeb.ExampleLive.Ask}
          current_project={@current_project}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    num_sources =
      socket.assigns.current_project
      |> Ash.load!(:num_sources)
      |> Map.get(:num_sources)

    {:ok, assign(socket, num_sources: num_sources)}
  end
end
