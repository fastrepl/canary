defmodule CanaryWeb.ProjectsLive.Index do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(%{current_account: %{projects: projects}} = assigns) when projects == [] do
    ~H"""
    <div>
      <div class="mb-4">
        <h2>Projects</h2>
        <.modal id="project-form">
          <.live_component
            id="project-form"
            module={CanaryWeb.ProjectsLive.Create}
            current_account={@current_account}
          />
        </.modal>
      </div>

      <div class="w-full h-[calc(100vh-300px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
        <p class="text-lg">
          You don't have any <span class="text-underline">projects</span> yet.
        </p>
        <.button is_primary phx-click={show_modal("project-form")}>
          Create your first project!
        </.button>
      </div>
    </div>
    """
  end

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

      <Primer.box is_scrollable style="max-height: 600px; margin-top: 18px">
        <:row :for={project <- @current_account.projects}>
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
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:projects])

    socket =
      socket
      |> assign_form_for_create()
      |> assign(current_account: account)

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
      {:ok, _record} ->
        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to create project")
          |> push_navigate(to: ~p"/projects")

        {:noreply, socket}
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("destroy", %{"item" => id}, socket) do
    project = socket.assigns.current_account.projects |> Enum.find(&(&1.id == id))

    case Ash.destroy(project, return_destroyed?: false) do
      {:error, error} -> IO.inspect(error)
      _ -> :ok
    end

    {:noreply, socket |> push_navigate(to: ~p"/projects")}
  end
end
