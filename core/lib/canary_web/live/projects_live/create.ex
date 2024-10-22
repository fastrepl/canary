defmodule CanaryWeb.ProjectsLive.Create do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        class="flex flex-col gap-4"
      >
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
        <.input type="text" autocomplete="off" field={f[:name]} label="Name" />

        <.button type="submit" is_primary>
          Create
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    form =
      Canary.Accounts.Project
      |> AshPhoenix.Form.for_create(:create,
        forms: [auto?: true],
        actor: socket.assigns.current_account
      )
      |> to_form()

    {:ok, socket |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/projects")}

      {:error,
       %Phoenix.HTML.Form{source: %AshPhoenix.Form{source: %Ash.Changeset{errors: errors}}} = form} ->
        if Enum.any?(errors, &match?(%Ash.Error.Forbidden.Policy{}, &1)) do
          socket =
            socket
            |> put_flash(:error, "Please upgrade your plan.")
            |> push_navigate(to: ~p"/projects")

          {:noreply, socket}
        else
          {:noreply, socket |> assign(:form, form)}
        end
    end
  end
end
