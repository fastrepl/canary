defmodule CanaryWeb.MembersLive.Invite do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="submit" class="flex flex-col gap-4">
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
        <Primer.text_input
          autocomplete="off"
          form={f}
          field={:email}
          type="email"
          form_control={%{label: "Email"}}
          is_full_width
          is_large
        />
        <Primer.button type="submit">
          Send
        </Primer.button>
      </.form>
    </div>
    """
  end

  @impl true
  @spec update(maybe_improper_list() | map(), any()) :: {:ok, any()}
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form()

    {:ok, socket}
  end

  defp assign_form(socket) do
    data = %{}
    types = %{email: :string, account_id: :string}
    params = %{email: "example@example.com", account_id: socket.assigns.current_account.id}

    form =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> to_form(as: :form)

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case Canary.Accounts.Invite
         |> Ash.Changeset.for_create(:create, params, actor: socket.assigns.current_account)
         |> Ash.create() do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/members")}

      error ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end
end
