defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <pre class="text-lg">try search here: </pre>
      <canary-root>
        <canary-provider-cloud
          project-key={@current_project.public_key}
          api-base={CanaryWeb.Endpoint.url()}
        >
          <canary-modal>
            <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content slot="content">
              <canary-input slot="input" autofocus></canary-input>
              <canary-search slot="mode">
                <canary-search-results slot="body"></canary-search-results>
              </canary-search>
              <canary-ask slot="mode">
                <canary-ask-results slot="body"></canary-ask-results>
              </canary-ask>
            </canary-content>
          </canary-modal>
        </canary-provider-cloud>
      </canary-root>

      <pre class="text-lg">For more information, please visit our <a href="https://getcanary.dev" target="_blank">documentation</a>.</pre>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    project = socket.assigns.current_project |> Ash.load!([:sources])

    socket =
      socket
      |> assign(sources: [])
      |> assign(current_project: project)

    {:ok, socket}
  end
end
