defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <canary-root>
        <canary-provider-cloud
          api-key={Enum.at(@current_account.keys, 0).value}
          api-base={CanaryWeb.Endpoint.url()}
          sources={
            @current_account.sources
            |> Enum.map(& &1.name)
            |> Enum.join(",")
          }
        >
          <canary-content>
            <canary-search slot="mode">
              <canary-search-input slot="input" autofocus></canary-search-input>
              <canary-search-suggestions slot="body" header="Ask AI"></canary-search-suggestions>
              <canary-search-results slot="body" header="Results"></canary-search-results>
            </canary-search>
            <canary-ask slot="mode">
              <canary-mode-breadcrumb slot="input-before" text="Ask AI"></canary-mode-breadcrumb>
              <canary-ask-input slot="input"></canary-ask-input>
              <canary-ask-results slot="body"></canary-ask-results>
            </canary-ask>
          </canary-content>
        </canary-provider-cloud>
      </canary-root>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    account =
      socket.assigns.current_account
      |> Ash.load!([:keys, :sources])

    socket =
      socket
      |> assign(current_account: account)

    {:ok, socket}
  end
end
