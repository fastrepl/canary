defmodule CanaryWeb.SourceLive.Create do
  use CanaryWeb, :live_component

  @config_types [
    {"Webpage", "webpage"},
    {"Github Issue", "github_issue"},
    {"Github Discussion", "github_discussion"}
  ]

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
        <input type="hidden" name={f[:project_id].name} value={@current_project.id} />

        <.inputs_for :let={fc} field={@form[:config]}>
          <.input
            type="select"
            field={fc[:_union_type]}
            options={@config_types}
            label="Type"
            phx-change="type-changed"
          />
          <.input
            type="text"
            field={f[:name]}
            placeholder="e.g. Docs"
            label="Name"
            autocomplete="off"
          />

          <%= case fc.params["_union_type"] do %>
            <% "webpage" -> %>
              <.input
                type="url"
                autocomplete="off"
                name={fc[:start_urls].name <> "[]"}
                value={fc[:start_urls].value}
                label="URL"
              />
            <% "github_issue" -> %>
              <.input autocomplete="off" field={fc[:owner]} placeholder="e.g. fastrepl" label="Owner" />
              <.input autocomplete="off" field={fc[:repo]} placeholder="e.g. canary" label="Repo" />
            <% "github_discussion" -> %>
              <.input autocomplete="off" field={fc[:owner]} placeholder="e.g. fastrepl" label="Owner" />
              <.input autocomplete="off" field={fc[:repo]} placeholder="e.g. canary" label="Repo" />
          <% end %>
        </.inputs_for>
        <.button type="submit" is_primary>Save</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:config_types, @config_types)

    form =
      Canary.Sources.Source
      |> AshPhoenix.Form.for_create(:create,
        forms: [auto?: true],
        actor: socket.assigns.current_account
      )
      |> then(fn form ->
        if form.forms[:config] do
          form
        else
          type = @config_types |> Enum.at(0) |> elem(1)
          AshPhoenix.Form.add_form(form, [:config], params: %{"_union_type" => type})
        end
      end)
      |> to_form()

    socket = socket |> assign(:form, form)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, %{id: id}} ->
        {:noreply, socket |> push_navigate(to: ~p"/source/#{id}")}

      {:error,
       %Phoenix.HTML.Form{source: %AshPhoenix.Form{source: %Ash.Changeset{errors: errors}}} = form} ->
        if Enum.any?(errors, &match?(%Ash.Error.Forbidden.Policy{}, &1)) do
          socket =
            socket
            |> put_flash(:error, "Please upgrade your plan.")
            |> push_navigate(to: ~p"/source")

          {:noreply, socket}
        else
          {:noreply, socket |> assign(:form, form)}
        end
    end
  end

  @impl true
  def handle_event("type-changed", %{"_target" => path} = params, socket) do
    new_type = get_in(params, path)
    path = :lists.droplast(path)

    form =
      socket.assigns.form
      |> AshPhoenix.Form.remove_form(path)
      |> AshPhoenix.Form.add_form(path, params: %{"_union_type" => new_type})

    {:noreply, assign(socket, :form, form)}
  end
end
