defmodule CanaryWeb.OnboardingLive.FirstProject do
  use CanaryWeb, :live_component
  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <div class="mb-3">
        <h2>Let's setup your first project!</h2>
        <p>Project can have multiple sources.</p>
      </div>

      <div class="flex flex-row gap-8 mt-4">
        <div class="flex flex-col gap-4 basis-1/2">
          <div><strong>Most of the time,</strong> you'll want to create a new project. ↓</div>
          <.form
            :let={f}
            for={@create_form}
            phx-target={@myself}
            phx-change="validate-create"
            phx-submit="save-create"
            class="flex flex-col gap-2 basis-1/2"
          >
            <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
            <.input field={f[:name]} label="Name" />
            <.button type="submit" is_primary>Create new</.button>
          </.form>
        </div>

        <div class="flex flex-col gap-4 basis-1/2">
          <div>
            If you are coming from a <strong>prebuilt demo</strong>, you can just take it as is. ↓
          </div>
          <.form
            :let={f}
            for={@clone_form}
            phx-target={@myself}
            phx-submit="save-clone"
            class="flex flex-col gap-2"
          >
            <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
            <.input field={f[:project_id]} label="ID (should be copied from demo)" />
            <.button type="submit" is_primary>Clone from existing</.button>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      socket
      |> assign(:clone_form, clone_form())
      |> assign(:create_form, create_form(socket))

    {:ok, socket}
  end

  defp create_form(socket) do
    Canary.Accounts.Project
    |> AshPhoenix.Form.for_create(:create,
      forms: [auto?: true],
      actor: socket.assigns.current_account
    )
    |> to_form()
  end

  defp clone_form(params \\ %{}) do
    data = %{project_id: ""}
    types = %{project_id: :string}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:project_id])
    |> Ecto.Changeset.validate_change(:project_id, fn field, id ->
      case get_project(id) do
        {:ok, _} -> []
        _ -> [{field, {"is invalid id", [validation: :data_layer]}}]
      end
    end)
    |> Map.put(:action, :validate)
    |> to_form(as: "form")
  end

  @impl true
  def handle_event("validate-create", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.create_form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save-create", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.create_form, params: params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Your project has been created!")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, socket |> assign(:form, form)}
    end
  end

  def handle_event("save-clone", %{"form" => params}, socket) do
    form = clone_form(params)

    if form.source.valid? do
      case get_project!(params["project_id"])
           |> Ash.Changeset.for_update(:transfer, %{account_id: params["account_id"]})
           |> Ash.update() do
        {:ok, _} ->
          {:noreply, socket |> push_navigate(to: ~p"/")}

        {:error, error} ->
          IO.inspect(error)
          {:noreply, socket |> put_flash(:error, error) |> push_navigate(to: ~p"/")}
      end
    else
      {:noreply, assign(socket, :clone_form, form)}
    end
  end

  defp get_project!(id) do
    {:ok, project} = get_project(id)
    project
  end

  defp get_project(project_id) do
    Canary.Accounts.Project
    |> Ash.Query.filter(public == true)
    |> Ash.Query.filter(id == ^project_id)
    |> Ash.read_one()
  end
end
