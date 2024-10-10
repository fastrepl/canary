defmodule CanaryWeb.SettingsLive.Projects do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>
        Projects
        <:actions>
          <Primer.button is_primary phx-click={Primer.open_dialog("project-form")}>
            New
          </Primer.button>
        </:actions>
      </Primer.subhead>

      <Primer.dialog id="project-form" is_backdrop>
        <:header_title>Create a new project</:header_title>
        <:body>
          <.live_component
            id="project-form"
            module={CanaryWeb.SettingsLive.CreateProject}
            current_account={@current_account}
          />
        </:body>
      </Primer.dialog>

      <Primer.box is_scrollable style="max-height: 400px; margin-top: 18px">
        <:row :for={project <- @projects}>
          <span><%= project.name %></span>
        </:row>
      </Primer.box>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    projects =
      socket.assigns.current_account
      |> Ash.load!(projects: [:sources])
      |> Map.get(:projects)

    socket =
      socket
      |> assign_form_for_create()
      |> assign(projects: projects)

    {:ok, socket}
  end

  defp assign_form_for_create(socket) do
    form =
      Canary.Accounts.Project
      |> AshPhoenix.Form.for_create(:create)
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, record} ->
        {:noreply, socket |> assign(:current_project, record)}

      {:error, updated_form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, updated_form)}
    end

    {:noreply, socket}
  end
end
