defmodule CanaryWeb.SettingsLive.SubdomainForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Subdomain</Primer.subhead>

      <.form :let={f} for={@form} phx-submit="submit" phx-target={@myself} class="flex flex-col gap-2">
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
        <Primer.text_input
          form={f}
          field={:name}
          disabled={@current_account.subdomain != nil}
          form_control={%{label: "Name"}}
        />
        <Primer.text_input
          form={f}
          field={:host}
          disabled={@current_account.subdomain != nil}
          form_control={%{label: "Host"}}
        />
        <%= if @current_account.subdomain do %>
          <.inputs_for :let={fc} field={f[:config]}>
            <Primer.text_input form={fc} field={:name} form_control={%{label: "Brand name"}} />
            <Primer.text_input form={fc} field={:logo_url} form_control={%{label: "Brand logo URL"}} />
          </.inputs_for>
        <% end %>

        <div class="flex flex-row mt-4 gap-2 justify-end">
          <%= if @current_account.subdomain do %>
            <Primer.button type="button" phx-click="destroy" phx-target={@myself} is_danger>
              Delete
            </Primer.button>
          <% end %>

          <Primer.button type="submit" is_primary>
            <%= @submit_text %>
          </Primer.button>
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
        |> AshPhoenix.Form.for_update(:update_config, forms: [auto?: true])
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
