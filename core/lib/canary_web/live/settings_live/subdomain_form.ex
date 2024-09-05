defmodule CanaryWeb.SettingsLive.SubdomainForm do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 id="subdomain" class="font-semibold mb-2">
        <a href="#subdomain" class="link link-hover"># Subdomain</a>
      </h2>

      <.form :let={f} for={@form} phx-submit="submit" phx-target={@myself} class="flex flex-col gap-2">
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />

        <label class="form-control w-full">
          <div class="label">
            <span class="label-text">Name</span>
          </div>
          <input
            name={f[:name].name}
            value={f[:name].value}
            type="text"
            placeholder="name"
            disabled={@current_account.subdomain != nil}
            class="input input-bordered w-full"
          />
        </label>

        <label class="form-control w-full">
          <div class="label">
            <span class="label-text">Host</span>

            <%= if f[:name].value do %>
              <span class="label-text-alt">
                <div class="badge bg-green-100 gap-2">
                  <%= "#{f[:name].value}.#{CanaryWeb.Endpoint.host()}" %>
                </div>
              </span>
            <% end %>
          </div>
          <input
            name={f[:host].name}
            value={f[:host].value}
            type="text"
            placeholder="host"
            disabled={@current_account.subdomain != nil}
            class="input input-bordered w-full"
          />
        </label>

        <%= if @current_account.subdomain do %>
          <.inputs_for :let={fc} field={f[:config]}>
            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Name</span>
              </div>
              <input
                name={fc[:name].name}
                value={fc[:name].value}
                type="text"
                placeholder="name"
                class="input input-bordered w-full"
              />
            </label>

            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Logo URL</span>
              </div>

              <input
                name={fc[:logo_url].name}
                value={fc[:logo_url].value}
                type="text"
                placeholder="logo_url"
                class="input input-bordered w-full"
              />
            </label>
          </.inputs_for>
        <% end %>

        <div class="flex flex-row mt-4 gap-2 justify-end">
          <%= if @current_account.subdomain do %>
            <button
              type="button"
              phx-click="destroy"
              phx-target={@myself}
              class="btn btn-sm bg-red-200"
            >
              Remove
            </button>
          <% end %>

          <button type="submit" class="btn btn-neutral btn-sm">
            <%= @submit_text %>
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form()

    {:ok, socket}
  end

  defp assign_form(socket) do
    account = socket.assigns.current_account |> Ash.load!([:subdomain])
    socket = socket |> assign(:current_account, account)

    if account.subdomain do
      form =
        account.subdomain
        |> AshPhoenix.Form.for_update(:update_config,
          forms: [
            config: [
              resource: Canary.Accounts.SubdomainConfig,
              data: account.subdomain.config,
              create_action: :create,
              update_action: :update
            ]
          ]
        )
        |> then(fn form ->
          if form.forms[:config] do
            form
          else
            AshPhoenix.Form.add_form(form, [:config])
          end
        end)
        |> to_form()

      socket =
        socket
        |> assign(:form, form)
        |> assign(:submit_text, "Update")

      socket
    else
      form =
        Canary.Accounts.Subdomain
        |> AshPhoenix.Form.for_create(:create)

      socket
      |> assign(:form, form)
      |> assign(:submit_text, "Create")
    end
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _record} ->
        {:noreply, assign_form(socket)}

      {:error, updated_form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, updated_form)}
    end
  end

  def handle_event("destroy", _, socket) do
    case Ash.destroy(socket.assigns.current_account.subdomain) do
      :ok ->
        {:noreply, assign_form(socket)}

      error ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end
end
