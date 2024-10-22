defmodule CanaryWeb.ProjectsLive.Index do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between items-center mb-4">
        <h2>Projects</h2>

        <div>
          <.button is_primary phx-click={show_modal("project-form")}>
            New
          </.button>
          <.modal id="project-form">
            <.live_component
              id="project-form"
              module={CanaryWeb.ProjectsLive.Create}
              current_account={@current_account}
            />
          </.modal>
        </div>
      </div>

      <%= if length(@projects) > 0 do %>
        <Primer.box is_scrollable style="max-height: 400px; margin-top: 18px">
          <:row :for={project <- @projects}>
            <div class="flex flex-row items-center justify-between">
              <span><%= project.name %></span>

              <div class="flex flex-row items-center gap-12">
                <div class="flex flex-row items-center gap-2">
                  <span class="text-gray-500">project_key: </span>
                  <div class="flex flex-row items-center gap-2 max-w-[150px]">
                    <Primer.text_input
                      autocomplete="off"
                      value={project.public_key}
                      disabled
                      is_small
                      is_full_width
                    >
                      <:group_button>
                        <Primer.button
                          aria-label="Copy"
                          id={"project-key-#{project.public_key}"}
                          phx-hook="Clipboard"
                          data-clipboard-text={project.public_key}
                          is_small
                        >
                          <Primer.octicon name="paste-16" />
                        </Primer.button>
                      </:group_button>
                    </Primer.text_input>
                  </div>
                </div>

                <.button type="button" phx-click="destroy" phx-value-item={project.id} is_danger>
                  Delete
                </.button>
              </div>
            </div>
          </:row>
        </Primer.box>
      <% else %>
        <Primer.box>
          <Primer.blankslate is_spacious>
            <:heading>
              You don't have any projects yet
            </:heading>
            <p>A single project can contain multiple sources, like web pages, GitHub issues, etc.</p>

            <:action>
              <Primer.button is_primary phx-click={Primer.open_dialog("project-form")}>
                Create project
              </Primer.button>
            </:action>
            <:action>
              <Primer.button is_link href="https://getcanary.dev">Learn more</Primer.button>
            </:action>
          </Primer.blankslate>
        </Primer.box>
      <% end %>
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

  @impl true
  def handle_event("destroy", %{"item" => id}, socket) do
    project = socket.assigns.projects |> Enum.find(&(&1.id == id))

    case Ash.destroy(project, return_destroyed?: false) do
      {:error, error} -> IO.inspect(error)
      _ -> :ok
    end

    {:noreply, socket |> push_navigate(to: ~p"/projects")}
  end
end
