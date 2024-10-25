defmodule CanaryWeb.SourceLive.GithubForm do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        id="form"
        for={@form}
        phx-submit="submit"
        phx-change="validate"
        phx-target={@myself}
        class="flex flex-col gap-4"
      >
        <.input
          autocomplete="off"
          name="type"
          value={
            case @source.config.type do
              :github_issue -> "Github Issue"
              :github_discussion -> "Github Discussion"
            end
          }
          disabled
          label="Type"
        />
        <.input autocomplete="off" field={f[:name]} label="Name" />

        <.inputs_for :let={fc} field={f[:config]}>
          <%= case @source.config.type do %>
            <% :github_issue -> %>
              <.input autocomplete="off" field={fc[:owner]} label="Owner" />
              <.input autocomplete="off" field={fc[:repo]} label="Repository" />
            <% :github_discussion -> %>
              <.input autocomplete="off" field={fc[:owner]} label="Owner" />
              <.input autocomplete="off" field={fc[:repo]} label="Repository" />
          <% end %>
        </.inputs_for>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form()

    {:ok, socket}
  end

  defp assign_form(socket) do
    form =
      socket.assigns.source
      |> AshPhoenix.Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Source has been updated!")
          |> push_navigate(to: ~p"/source/#{socket.assigns.source.id}")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to update source.")

        {:noreply, socket}
    end
  end
end
