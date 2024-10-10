defmodule CanaryWeb.SourceLive.Create do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

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
          <div class="flex flex-row gap-2">
            <Primer.select
              form={fc}
              field={:_union_type}
              options={@config_types}
              form_control={%{label: "Type"}}
              phx-change="type-changed"
            />
            <Primer.text_input
              form={f}
              field={:name}
              placeholder="e.g. Docs"
              form_control={%{label: "Name"}}
            />
          </div>

          <%= case fc.params["_union_type"] do %>
            <% "webpage" -> %>
              <Primer.text_input
                type="url"
                name={fc[:start_urls].name <> "[]"}
                value={fc[:start_urls].value}
                form_control={%{label: "URL"}}
                is_full_width
              />
            <% "github_issue" -> %>
              <Primer.text_input
                form={fc}
                field={:owner}
                placeholder="e.g. fastrepl"
                form_control={%{label: "Owner"}}
                is_full_width
              />
              <Primer.text_input
                form={fc}
                field={:repo}
                placeholder="e.g. canary"
                form_control={%{label: "Repo"}}
                is_full_width
              />
            <% "github_discussion" -> %>
              <Primer.text_input
                form={fc}
                field={:owner}
                placeholder="e.g. fastrepl"
                form_control={%{label: "Owner"}}
                is_full_width
              />
              <Primer.text_input
                form={fc}
                field={:repo}
                placeholder="e.g. canary"
                form_control={%{label: "Repo"}}
                is_full_width
              />
          <% end %>
        </.inputs_for>
        <Primer.button is_submit>Save</Primer.button>
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
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true])
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

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
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
