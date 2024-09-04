defmodule CanaryWeb.SettingsSubdomainLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} class="flex flex-col gap-4" phx-submit="submit">
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
        <.input field={f[:name]} type="text" placeholder="name" class="input input-bordered w-full" />
        <.input field={f[:host]} type="text" placeholder="host" class="input input-bordered w-full" />
        <button type="submit" class="btn btn-neutral btn-sm">
          <%= @submit_text %>
        </button>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_account = Ash.load!(socket.assigns.current_account, [:subdomain])

    socket =
      if current_account.subdomain do
        assign_destroy(socket, current_account.subdomain)
      else
        assign_create(socket)
      end

    socket =
      socket
      |> assign(:current_account, current_account)

    {:ok, socket}
  end

  defp assign_create(socket) do
    socket
    |> assign(:form, AshPhoenix.Form.for_create(Canary.Accounts.Subdomain, :create))
    |> assign(:submit_text, "Save")
  end

  defp assign_destroy(socket, record) do
    socket
    |> assign(:form, AshPhoenix.Form.for_destroy(record, :destroy))
    |> assign(:submit_text, "Remove")
  end

  def handle_event("submit", %{"form" => form}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form) do
      :ok -> {:noreply, assign_create(socket)}
      {:ok, record} -> {:noreply, assign_destroy(socket, record)}
      {:error, form} -> {:noreply, assign(socket, :form, form)}
    end
  end
end
