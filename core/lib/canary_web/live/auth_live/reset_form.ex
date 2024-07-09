defmodule CanaryWeb.AuthLive.ResetForm do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form class="flex flex-col justify-center gap-4 px-10 py-10 lg:px-16">
        <div class="alert alert-success text-xs">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5 shrink-0 stroke-current"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>Recovery email sent successfully</span>
        </div>

        <div class="form-control">
          <label class="label" for="input1"><span class="label-text">Email</span></label>
          <input
            type="email"
            placeholder="email"
            class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
            required
            id="input1"
          />
        </div>
        <button class="btn btn-neutral" type="submit">Recover</button>
        <div class="label justify-end">
          <.link class="link-hover link label-text-alt" navigate={@alternative_path}>
            <%= @alternative_message %>
          </.link>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
