defmodule CanaryWeb.OnboardingLive.CodeExample do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <pre
        class="border border-gray-200 p-2 rounded-md"
        id={@id}
        phx-hook="Highlight"
        class="lang-html"
      ><code><%= @code %></code></pre>

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
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    project = assigns.current_project

    code = """
    <canary-root>
      <canary-provider-cloud project-key="#{project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content>
              <canary-input slot="input"></canary-input>
              <canary-search slot="mode">
                <canary-search-results slot="body"></canary-search-results>
              </canary-search>
            </canary-content>
        </canary-modal>
      </canary-provider-cloud>
    </canary-root>
    """

    socket =
      socket
      |> assign(assigns)
      |> assign(:code, code)

    {:ok, socket}
  end
end
