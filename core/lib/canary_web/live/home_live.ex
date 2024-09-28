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
            <%= @action_message %>
          </:heading>
          <:action>
            <Primer.button is_primary href={@action_url}>Create</Primer.button>
          </:action>
        </Primer.blankslate>
      </Primer.box>
    <% else %>
      <div class="flex flex-col gap-4">
        <pre class="text-lg">try our search here: </pre>
        <canary-root>
          <canary-provider-cloud
            api-key={Enum.at(@current_account.keys, 0).value}
            api-base={CanaryWeb.Endpoint.url()}
            sources={@sources}
          >
            <canary-modal>
              <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
              <canary-content slot="content">
                <canary-input slot="input"></canary-input>
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
      |> assign(sources: ["litellm"])
      |> assign(current_account: account)
      |> assign(valid: Enum.count(account.keys) > 0 && Enum.count(account.sources) > 0)
      |> assign(
        cond do
          Enum.count(account.keys) == 0 ->
            [
              action_message: "You don't have any keys yet. Please create one.",
              action_url: "/settings"
            ]

          Enum.count(account.sources) == 0 ->
            [
              action_message: "You don't have any sources yet. Please create one.",
              action_url: "/source"
            ]

          true ->
            []
        end
      )

    {:ok, socket}
  end
end
