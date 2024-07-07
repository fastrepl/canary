defmodule CanaryWeb.GithubSetupLive do
  use CanaryWeb, :live_view
  alias Canary.Github.App

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto mt-[100px]">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold">
          GitHub Integration Setup
        </h1>
        <p>Please follow the steps below.</p>
      </div>

      <div class="join join-vertical w-full">
        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input type="radio" name="accordion" checked={if(@current == 0, do: "checked")} />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={0} current={@current} /> Installing GitHub app to repositories
          </div>
          <div class="collapse-content">
            We assume the app is installed if 'installation_id' is provided in the URL.
            If you are stuck here,
            please <a
              class="link"
              href={Application.get_env(:canary, :github_app_url)}
              target="_blank"
            >reinstall the app</a>.
          </div>
        </div>

        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input type="radio" name="accordion" checked={if(@current == 1, do: "checked")} />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={1} current={@current} /> Checking repository access
          </div>
          <div class="collapse-content">
            We listen to the webhooks from GitHub for this.
            If you stuck here,
            please <a
              class="link"
              href={Application.get_env(:canary, :github_app_url)}
              target="_blank"
            >reinstall the app</a>.
          </div>
        </div>

        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input type="radio" name="accordion" checked={if(@current == 2, do: "checked")} />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={2} current={@current} /> Linking Canary account
          </div>
          <div class="collapse-content">
            <p class="mb-2">
              If you have multiple accounts, please select the account you want to link to this app.
            </p>

            <div class="flex flex-row items-center gap-1">
              <select class="select select-bordered select-sm w-[120px]" disabled={@current != 2}>
                <option selected>
                  <%= @current_account.name %>
                </option>
              </select>
              <button phx-click="link_account" class="btn btn-sm btn-neutral" disabled={@current != 2}>
                Use this account
              </button>
            </div>
          </div>
        </div>
      </div>

      <%= if @current == 3 do %>
        <div class="mt-12 flex flex-row items-center gap-2">
          <p class="text-md">All done!</p>
          <a class="link" href={~p"/settings"}>Go to settings</a>
        </div>
      <% end %>
    </div>
    """
  end

  attr :n, :integer
  attr :current, :integer

  def status(assigns) do
    ~H"""
    <%= cond do %>
      <% @current == @n -> %>
        <span class="loading loading-ball loading-sm"></span>
      <% @current > @n -> %>
        <input type="checkbox" class="checkbox checkbox-sm" checked="checked" } />
      <% true -> %>
        <input type="checkbox" class="checkbox checkbox-sm" />
    <% end %>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:github_app, nil)
      |> assign(:installation_id, params["installation_id"])
      |> assign(:current, if(params["installation_id"], do: 1, else: 0))

    send(self(), :check_app)
    {:ok, socket}
  end

  @impl true
  def handle_info(:check_app, socket) do
    case App.find(socket.assigns.installation_id) do
      {:ok, app} ->
        {:noreply, socket |> assign(github_app: app) |> assign(:current, 2)}

      _ ->
        Process.send_after(self(), :check_app, 1200)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("link_account", _, socket) do
    case Canary.Github.App.link_account(socket.assigns.github_app, socket.assigns.current_account) do
      {:ok, _} -> {:noreply, socket |> assign(:current, 3)}
      _ -> {:noreply, socket}
    end
  end
end
