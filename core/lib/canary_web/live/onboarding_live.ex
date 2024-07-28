defmodule CanaryWeb.OnboardingLive do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto mt-[100px]">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold">
          🐤 Canary Onboarding
        </h1>
        <p>Please follow the steps below.</p>
      </div>

      <div class="join join-vertical w-full">
        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input
            type="radio"
            name="accordion"
            checked={if(@current == 0, do: "checked")}
            disabled={@current > 0}
          />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={0} current={@current} /> Creating a new project
          </div>
          <div class="collapse-content">
            <p class="text-sm">
              Each project can be shared with multiple members.
              You can invite members to your project later.
            </p>
            <.form :let={f} phx-submit="account" for={@account_form} class="mt-2">
              <div class="flex flex-col gap-2">
                <div class="form-control">
                  <label class="label"><span class="label-text">Project Name</span></label>
                  <input
                    name={f[:name].name}
                    value={f[:name].value}
                    type="text"
                    autocomplete="off"
                    class="input input-bordered w-full"
                  />
                </div>
                <button type="submit" class="btn btn-neutral btn-sm">
                  Create
                </button>
              </div>
            </.form>
          </div>
        </div>

        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input
            type="radio"
            name="accordion"
            checked={if(@current == 1, do: "checked")}
            disbaled={@current > 1}
          />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={1} current={@current} /> Setting up primary source
          </div>
          <div class="collapse-content">
            <p class="text-sm">
              Let's start with your public documentation website.
            </p>

            <.form :let={f} phx-submit="web_source" for={@web_source_form} class="mt-2">
              <div class="flex flex-col gap-2">
                <div class="form-control">
                  <label class="label"><span class="label-text">Documentation URL</span></label>
                  <input
                    name={f[:web_base_url].name}
                    value={f[:web_base_url].value}
                    type="url"
                    autocomplete="off"
                    class="input input-bordered w-full"
                  />
                </div>
                <button type="submit" class="btn btn-neutral btn-sm">
                  Process
                </button>
              </div>
            </.form>
          </div>
        </div>

        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input
            type="radio"
            name="accordion"
            checked={if(@current == 2, do: "checked")}
            disabled={@current > 2}
          />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={2} current={@current} /> Connecting to Website
          </div>
          <div class="collapse-content">
            <p class="text-sm">
              In most cases, this will be the same as the documentation URL you provided in the previous step.
            </p>

            <.form :let={f} phx-submit="web_client" for={@web_client_form} class="mt-2">
              <div class="flex flex-col gap-2">
                <div class="form-control">
                  <label class="label"><span class="label-text">Website URL</span></label>
                  <input
                    name={f[:web_url].name}
                    value={f[:web_url].value}
                    type="url"
                    autocomplete="off"
                    class="input input-bordered w-full"
                  />
                </div>
                <button type="submit" class="btn btn-neutral btn-sm">
                  Connect
                </button>
              </div>
            </.form>
          </div>
        </div>

        <div class="collapse collapse-arrow join-item border-base-300 border">
          <input
            type="radio"
            name="accordion"
            checked={if(@current == 3, do: "checked")}
            disabled={@current > 3}
          />
          <div class="collapse-title text-lg font-medium flex flex-row items-center gap-2">
            <.status n={3} current={@current} /> Connecting to Discord
          </div>
          <div class="collapse-content">
            <p class="text-sm">
              You can skip this step if you don't have a Discord server.
            </p>

            <.form :let={f} phx-submit="discord_client" for={@discord_client_form} class="mt-2">
              <div class="flex flex-col gap-2">
                <div class="form-control">
                  <label class="label"><span class="label-text">Server ID</span></label>
                  <input
                    name={f[:discord_server_id].name}
                    value={f[:discord_server_id].value}
                    type="number"
                    autocomplete="off"
                    class="input input-bordered w-full"
                  />

                  <label class="label"><span class="label-text">Channel ID</span></label>
                  <input
                    name={f[:discord_channel_id].name}
                    value={f[:discord_channel_id].value}
                    type="number"
                    autocomplete="off"
                    class="input input-bordered w-full"
                  />
                </div>
                <button type="button" class="btn btn-sm" phx-click="skip">
                  Skip
                </button>
                <button type="submit" class="btn btn-neutral btn-sm">
                  Connect
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>

      <%= if @current == 4 do %>
        <div class="mt-12 flex flex-row items-center gap-2">
          <p class="text-md">All done!</p>
          <a class="link" href={~p"/"}>Go to dashboard</a>
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
  def mount(_params, _session, socket) do
    current =
      cond do
        socket.assigns.current_account == nil -> 0
        socket.assigns.current_account.sources == [] -> 1
        socket.assigns.current_account.clients == [] -> 2
        true -> 3
      end

    socket =
      socket
      |> assign(:current, current)
      |> assign(
        :account_form,
        AshPhoenix.Form.for_create(Canary.Accounts.Account, :create)
      )
      |> assign(
        :web_source_form,
        AshPhoenix.Form.for_create(Canary.Sources.Source, :create_web)
      )
      |> assign(
        :web_client_form,
        AshPhoenix.Form.for_create(Canary.Interactions.Client, :create_web)
      )
      |> assign(
        :discord_client_form,
        AshPhoenix.Form.for_create(Canary.Interactions.Client, :create_discord)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("account", %{"form" => inputs}, socket) do
    params = Map.put(inputs, "user", socket.assigns.current_user)

    case AshPhoenix.Form.submit(socket.assigns.account_form, params: params) do
      {:ok, account} ->
        {:noreply, socket |> assign(:current, 1) |> assign(:current_account, account)}

      {:error, form} ->
        {:noreply, socket |> assign(:account_form, AshPhoenix.Form.clear_value(form, [:name]))}
    end
  end

  @impl true
  def handle_event("web_source", %{"form" => inputs}, socket) do
    params = Map.put(inputs, "account", socket.assigns.current_account)

    case AshPhoenix.Form.submit(socket.assigns.web_source_form, params: params) do
      {:ok, source} ->
        Canary.Workers.Fetcher.new(%{source_id: source.id}) |> Oban.insert()
        {:noreply, socket |> assign(:current_source, source) |> assign(:current, 2)}

      {:error, form} ->
        {:noreply,
         socket |> assign(:web_source_form, AshPhoenix.Form.clear_value(form, [:web_base_url]))}
    end
  end

  @impl true
  def handle_event("web_client", %{"form" => inputs}, socket) do
    params = Map.put(inputs, "account", socket.assigns.current_account)

    case AshPhoenix.Form.submit(socket.assigns.web_client_form, params: params) do
      {:ok, client} ->
        Canary.Interactions.Client.add_sources(client, [socket.assigns.current_source])
        {:noreply, socket |> assign(:current, 3)}

      {:error, form} ->
        {:noreply,
         socket |> assign(:web_client_form, AshPhoenix.Form.clear_value(form, [:web_url]))}
    end
  end

  @impl true
  def handle_event("discord_client", %{"form" => inputs}, socket) do
    params = Map.put(inputs, "account", socket.assigns.current_account)

    case AshPhoenix.Form.submit(socket.assigns.discord_client_form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> assign(:current, 4)}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(
           :discord_client_form,
           AshPhoenix.Form.clear_value(form, [:discord_server_id, :discord_channel_id])
         )}
    end
  end

  @impl true
  def handle_event("skip", _, socket) do
    {:noreply, socket |> assign(:current, socket.assigns.current + 1)}
  end
end
