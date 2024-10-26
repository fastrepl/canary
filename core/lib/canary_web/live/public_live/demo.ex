defmodule CanaryWeb.PublicLive.Demo do
  use CanaryWeb, :live_view
  require Ash.Query

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
      <h2>Canary Demo</h2>
      <div>
        After <.link navigate="/" class="text-blue-500 underline">
          creating your account,
        </.link>fill in the ID below when creating a new project. <pre class="mt-2"><%= @current_project.id %></pre>
      </div>

      <div class="py-4">
        <div class="flex flex-col gap-4">
          <.live_component
            id="example-search"
            module={CanaryWeb.ExampleLive.Search}
            current_project={@current_project}
          />

          <.live_component
            id="example-ask"
            module={CanaryWeb.ExampleLive.Ask}
            current_project={@current_project}
          />
        </div>
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
           |> Ash.read_one() do
        {:ok, project} -> assign(socket, current_project: project)
        _ -> assign(socket, current_project: nil)
      end

    {:ok, socket}
  end
end
