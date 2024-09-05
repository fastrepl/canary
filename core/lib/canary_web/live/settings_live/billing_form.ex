defmodule CanaryWeb.SettingsLive.BillingForm do
  use CanaryWeb, :live_component

  alias Canary.Accounts.Billing

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 id="billing" class="font-semibold mb-2">
        <a href="#billing" class="link link-hover"># Billing</a>
      </h2>

      <label class="form-control w-full">
        <div class="label">
          <span class="label-text">Current plan</span>
        </div>
        <input class="input input-bordered" value={@plan} disabled />
      </label>

      <div class="flex flex-row gap-2 mt-4 justify-end">
        <%= if @current_account.billing.stripe_subscription do %>
          <.link href={@stripe_portal_url} class="btn btn-neutral btn-sm">
            Manage
          </.link>
        <% else %>
          <button
            type="button"
            phx-click="checkout"
            phx-target={@myself}
            class="btn btn-neutral btn-sm"
          >
            Upgrade
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    stripe_portal_url =
      Application.get_env(:canary, :stripe)
      |> Keyword.fetch!(:customer_portal_url)

    billing = assigns.current_account.billing

    socket =
      socket
      |> assign(assigns)
      |> assign(:plan, if(billing.stripe_subscription, do: "Pro", else: "Free"))
      |> assign(:stripe_portal_url, stripe_portal_url)

    {:ok, socket}
  end

  @impl true
  def handle_event("checkout", _, %{assigns: %{current_account: current_account}} = socket) do
    if current_account.billing.stripe_customer == nil do
      params = %{metadata: %{"account_id" => current_account.id}}

      with {:ok, customer} <- Stripe.Customer.create(params),
           {:ok, _} <- Billing.update_stripe_customer(current_account.billing, customer) do
        {:noreply, socket |> redirect(to: ~p"/checkout")}
      else
        {:error, error} ->
          {:noreply, socket |> put_flash(:error, error)}
      end
    else
      {:noreply, socket |> redirect(to: ~p"/checkout")}
    end
  end
end
