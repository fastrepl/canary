defmodule CanaryWeb.SettingsLive do
  use CanaryWeb, :live_view

  alias Canary.Accounts.Billing

  def render(assigns) do
    ~H"""
    <div class="divide-y">
      <div class="grid max-w-7xl grid-cols-1 gap-x-8 gap-y-10 px-4 py-16 sm:px-6 md:grid-cols-3 lg:px-8">
        <div>
          <h2 id="account" class="font-semibold leading-7">
            <a href="#account" class="link link-hover">Account</a>
          </h2>
          <p class="mt-1 text-sm leading-6">
            Update your account information.
          </p>
        </div>

        <.form :let={f} for={@account_form} class="md:col-span-2" phx-submit="account">
          <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:max-w-xl sm:grid-cols-6">
            <div class="col-span-full">
              <label for="name" class="block text-sm font-medium leading-6">Name</label>
              <div class="mt-2">
                <input
                  name={f[:name].name}
                  value={f[:name].value}
                  type="text"
                  class="block w-full rounded-md border-0 bg-white/5 py-1.5 shadow-sm ring-1 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-indigo-500 sm:text-sm sm:leading-6"
                />
              </div>
            </div>

            <div class="col-span-full">
              <label for="members" class="block text-sm font-medium leading-6">Members</label>
              <div class="mt-2 text-sm">
                <p>Not available yet.</p>
              </div>
            </div>
          </div>

          <div class="flex flex-row gap-2 mt-8 justify-end">
            <button type="submit" class="btn btn-neutral btn-sm">
              Save
            </button>
          </div>
        </.form>
      </div>

      <div class="grid max-w-7xl grid-cols-1 gap-x-8 gap-y-10 px-4 py-16 sm:px-6 md:grid-cols-3 lg:px-8">
        <div>
          <h2 id="billing" class="font-semibold leading-7">
            <a href="#billing" class="link link-hover">Billing</a>
          </h2>
          <p class="mt-1 text-sm leading-6">
            Learn about our pricing at <a
              class="link"
              href="https://getcanary.dev#pricing"
              target="_blank"
            >getcanary.dev</a>.
          </p>
        </div>

        <form class="md:col-span-2">
          <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:max-w-xl sm:grid-cols-6">
            <div class="col-span-full">
              <label for="logout-password" class="block text-sm font-medium leading-6">
                Current plan
              </label>
              <div class="mt-2">
                <%= if @current_account.billing.stripe_subscription do %>
                  Pay as you go
                <% else %>
                  Free
                <% end %>
              </div>
            </div>
          </div>

          <div class="flex flex-row gap-2 mt-8 justify-end">
            <%= if @current_account.billing.stripe_subscription do %>
              <.link
                href={Keyword.fetch!(@stripe, :customer_portal_url)}
                class="btn btn-neutral btn-sm"
              >
                Manage
              </.link>
            <% else %>
              <button type="button" phx-click="checkout" class="btn btn-neutral btn-sm">
                Upgrade
              </button>
            <% end %>
          </div>
        </form>
      </div>

      <div class="grid max-w-7xl grid-cols-1 gap-x-8 gap-y-10 px-4 py-16 sm:px-6 md:grid-cols-3 lg:px-8">
        <div>
          <h2 id="github" class="font-semibold leading-7">
            <a href="#github" class="link link-hover">GitHub App</a>
          </h2>
          <p class="mt-1 text-sm leading-6">
            Install our app to access features like documentation editor. (Coming soon)
          </p>
        </div>

        <form class="md:col-span-2">
          <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:max-w-xl sm:grid-cols-6">
            <div class="col-span-full">
              <label for="current-password" class="block text-sm font-medium leading-6">
                Installed Repositories
              </label>
              <div class="mt-2 text-sm">
                <%= if @current_account.github_app do %>
                  <div class="collapse bg-base-200 hover:bg-base-300">
                    <input type="checkbox" />
                    <div class="collapse-title">
                      <%= @current_account.github_app.repos |> length() %> repositories
                    </div>
                    <div class="collapse-content">
                      <%= for repo <- @current_account.github_app.repos do %>
                        <p><%= repo.full_name %></p>
                      <% end %>
                    </div>
                  </div>
                <% else %>
                  None
                <% end %>
              </div>
            </div>
          </div>

          <div class="flex flex-row gap-2 mt-8 justify-end">
            <%= if @current_account.github_app do %>
              <.link
                class="btn btn-neutral btn-sm"
                href={Application.get_env(:canary, :github_app_url)}
              >
                Manage
              </.link>
            <% else %>
              <.link
                class="btn btn-neutral btn-sm"
                href={Application.get_env(:canary, :github_app_url)}
              >
                Install
              </.link>
            <% end %>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account =
      socket.assigns.current_account
      |> Ash.load!([:billing, github_app: [:repos]])

    socket =
      socket
      |> assign(current_account: account)
      |> assign(stripe: Application.get_env(:canary, :stripe))
      |> assign(:account_form, AshPhoenix.Form.for_update(account, :update))

    {:ok, socket}
  end

  def handle_event("account", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.account_form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> redirect(to: ~p"/settings")}

      {:error, form} ->
        {:noreply, socket |> assign(:account_form, AshPhoenix.Form.clear_value(form, [:name]))}
    end
  end

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
