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
            <canary-input slot="input"></canary-input>
            <canary-search slot="mode">
              <canary-search-suggestions slot="body"></canary-search-suggestions>
              <canary-search-results group slot="body"></canary-search-results>
              <canary-search-empty slot="body"></canary-search-empty>
            </canary-search>

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
