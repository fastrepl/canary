defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <%= if not @valid do %>
      <Primer.box>
        <Primer.blankslate is_spacious>
          <:heading>
            <%= @message %>
          </:heading>
          <:action>
            <Primer.button is_primary>New project</Primer.button>
          </:action>
          <:action>
            <Primer.button is_link>Learn more</Primer.button>
          </:action>
          <p>Use it to provide information when no dynamic content exists.</p>
        </Primer.blankslate>
      </Primer.box>
    <% else %>
      <div class="flex flex-col">
        <canary-root>
          <canary-provider-cloud
            api-key={Enum.at(@current_account.keys, 0).value}
            api-base={CanaryWeb.Endpoint.url()}
          >
            <canary-content>
              <canary-input slot="input"></canary-input>
              <canary-search slot="mode">
                <canary-search-results slot="body"></canary-search-results>
              </canary-search>
            </canary-content>
          </canary-provider-cloud>
        </canary-root>
      </div>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    account =
      socket.assigns.current_account
      |> Ash.load!([:keys, :sources])

    socket =
      socket
      |> assign(valid: Enum.count(account.keys) > 0 && Enum.count(account.sources) > 0)
      |> assign(
        message:
          cond do
            Enum.count(account.keys) == 0 ->
              "You don't have any keys yet. Please create one."

            Enum.count(account.sources) == 0 ->
              "You don't have any sources yet. Please create one."

            true ->
              nil
          end
      )
      |> assign(current_account: account)

    {:ok, socket}
  end
end
