defmodule CanaryWeb.PublicLive.Demo do
  use CanaryWeb, :live_view
  require Ash.Query

  alias PrimerLive.Component, as: Primer

  @impl true
  def render(%{current_project: nil} = assigns) do
    ~H"""
    <div class="w-full h-[100vh] flex flex-col items-center justify-center">
      <span class="text-xs">Not found</span>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="px-12 py-4">
      <h2 class="text-3xl">
        🐤 Canary demo for
        <span class="text-yellow-900 underline"><%= String.capitalize(@current_project.name) %></span>
      </h2>
      <div class="mt-2">
        Canary is <a href="https://github.com/fastrepl/canary" target="_blank">open source</a>, and we have hosted service at <a
          href="https://cloud.getcanary.dev"
          target="_blank"
        >cloud.getcanary.dev</a>.
      </div>
      <div class="mt-2">
        You can use the ID below to clone this demo project, after <.link navigate="/projects">creating your account</.link>.
        <div class="w-[320px] mt-2">
          <Primer.text_input value={@current_project.id} disabled is_small is_full_width>
            <:group_button>
              <Primer.button
                aria-label="Copy"
                phx-hook="Clipboard"
                id="project-key"
                data-clipboard-text={@current_project.id}
                is_small
              >
                <Primer.octicon name="paste-16" />
              </Primer.button>
            </:group_button>
          </Primer.text_input>
        </div>
      </div>

      <div class="py-4">
        <.live_component
          id="example-search"
          module={CanaryWeb.ExampleLive.Examples}
          current_project={@current_project}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      case Canary.Accounts.Project
           |> Ash.Query.filter(public == true)
           |> Ash.Query.filter(id == ^id)
           |> Ash.read_one(load: [:sources]) do
        {:ok, project} -> assign(socket, current_project: project)
        _ -> assign(socket, current_project: nil)
      end

    {:ok, socket}
  end
end
