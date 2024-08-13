defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <label class="form-control w-full max-w-xs mt-4">
        <div class="label">
          <span class="label-text">This is your public key.</span>
          <button
            id="pk"
            phx-hook="Clipboard"
            class="btn btn-sm btn-ghost"
            data-clipboard-text={@web_client.web_public_key}
          >
            Click here to copy
          </button>
        </div>
        <input
          type="text"
          value={@web_client.web_public_key}
          disabled
          class="input input-bordered w-full max-w-xs "
        />
        <div class="label"></div>
      </label>

      <span class="text-sm mb-2">Try it out!</span>
      <canary-root>
        <canary-provider-cloud key={@web_client.web_public_key} endpoint={CanaryWeb.Endpoint.url()}>
          <canary-modal>
            <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content slot="content">
              <canary-search slot="mode">
                <canary-search-input slot="input"></canary-search-input>
                <canary-search-results slot="result"></canary-search-results>
              </canary-search>
            </canary-content>
          </canary-modal>
        </canary-provider-cloud>
      </canary-root>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:clients])
    client = account.clients |> Enum.find(&(&1.type == :web))

    IO.inspect(client)

    socket =
      socket
      |> assign(web_client: client)

    {:ok, socket}
  end
end
