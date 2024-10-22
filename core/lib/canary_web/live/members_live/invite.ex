defmodule CanaryWeb.MembersLive.Invite do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="flex flex-col gap-4">
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />
        <.input type="email" field={f[:email]} autocomplete="off" label="Email" />
        <.button type="submit">Send</.button>
      </.form>
    </div>
    """
  end

  @impl true
  @spec update(maybe_improper_list() | map(), any()) :: {:ok, any()}
  def update(assigns, socket) do
    form =
      Canary.Accounts.Invite
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true], actor: assigns.current_account)
      |> to_form()

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, form)

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/members")}

      {:error,
       %Phoenix.HTML.Form{source: %AshPhoenix.Form{source: %Ash.Changeset{errors: errors}}} = form} ->
        if Enum.any?(errors, &match?(%Ash.Error.Forbidden.Policy{}, &1)) do
          socket =
            socket
            |> put_flash(:error, "Please upgrade your plan.")
            |> push_navigate(to: ~p"/members")

          {:noreply, socket}
        else
          {:noreply, socket |> assign(:form, form)}
        end
    end
  end
end
