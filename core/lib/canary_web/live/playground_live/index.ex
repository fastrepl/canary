defmodule CanaryWeb.PlaygroundLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-4">
        <h2>Playground</h2>
        <p>Copy-pastable examples, powered by your existing sources.</p>
      </div>

      <div class="flex flex-col gap-4">
        <.live_component
          id="playground-search"
          module={CanaryWeb.PlaygroundLive.Search}
          current_project={@current_project}
        />

        <.live_component
          id="playground-ask"
          module={CanaryWeb.PlaygroundLive.Ask}
          current_project={@current_project}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
