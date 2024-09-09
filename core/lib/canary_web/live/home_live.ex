defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <canary-root>
        <canary-provider-cloud
          api-key={@web_client.web_public_key}
          api-base={CanaryWeb.Endpoint.url()}
        >
          <canary-modal>
            <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content slot="content">
              <canary-search slot="mode">
                <canary-search-input slot="input" autofocus></canary-search-input>
                <canary-search-suggestions slot="body" header="Ask AI"></canary-search-suggestions>
                <canary-search-results slot="body" header="Results" limit="4"></canary-search-results>
              </canary-search>
              <canary-ask slot="mode">
                <canary-mode-breadcrumb slot="input-before" previous="Search" text="Ask AI">
                </canary-mode-breadcrumb>
                <canary-ask-input slot="input"></canary-ask-input>
                <canary-ask-results slot="body"></canary-ask-results>
              </canary-ask>
            </canary-content>
          </canary-modal>
        </canary-provider-cloud>
      </canary-root>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    key =
      socket.assigns.current_account
      |> Ash.load!([:keys])
      |> Map.get(:keys)
      |> Enum.at(0)

    socket =
      socket
      |> assign(web_client: %{web_public_key: key.value})

    {:ok, socket}
  end
end
