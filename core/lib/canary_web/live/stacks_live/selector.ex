defmodule CanaryWeb.StacksLive.Selector do
  use CanaryWeb, :live_component

  @items [
    %{
      name: "next-forge",
      logo_url: "/images/next-forge.svg"
    },
    %{
      name: "Turborepo",
      logo_url: "/images/turborepo.svg"
    },
    %{
      name: "Vercel",
      logo_url: "/images/vercel.svg"
    },
    %{
      name: "Next.js",
      logo_url: "/images/nextjs.svg",
      project_id: "TODO",
      tabs: []
    },
    %{
      name: "next-seo",
      logo_url: "/images/seo.svg"
    },
    %{
      name: "Shadcn",
      logo_url: "/images/shadcn.svg",
      project_id: "TODO",
      tabs: []
    },
    %{
      name: "React Email",
      logo_url: "/images/nextjs.svg",
      project_id: "TODO",
      tabs: []
    },
    %{
      name: "Prisma",
      logo_url: "/images/prisma.png",
      project_id: "TODO",
      tabs: []
    },
    %{
      name: "Clerk",
      logo_url: "/images/clerk.png",
      project_id: "TODO",
      tabs: []
    },
    %{
      name: "Stripe",
      logo_url: "/images/stripe.svg",
      project_id: "TODO",
      tabs: []
    }
  ]
  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="flex flex-col items-center my-4">
        <h1 class="text-4xl font-bold">
          Ask about
          <.link href="https://github.com/haydenbleasel/next-forge" class="underline">
            Next-Forge
          </.link>
        </h1>
        <p>
          Brought to you by <a href="https://github.com/fastrepl/canary" target="_blank">🐤 Canary</a>
        </p>

        <p class="mt-4">
          All public sources about next-forge are indexed.
        </p>
      </div>

      <div>
        <div class="grid grid-cols-5 gap-4">
          <%= for item <- @items do %>
            <div class="flex flex-col gap-2 items-center justify-center">
              <img src={item.logo_url} class="w-24 h-24 object-contain" />
              <p class="text-sm text-gray-500">
                <%= item.name %>
              </p>
            </div>
          <% end %>
        </div>
        <.button is_primary phx-target={@myself} phx-click="start" class="mt-4 w-full h-12">
          Get started
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:items, @items)

    {:ok, socket}
  end

  @impl true
  def handle_event("start", _, socket) do
    id = Ecto.UUID.generate()
    data = %{dataset_id: "prod_1feac9f6-f1f0-4f16-b0c3-6daa823ea7b3"}
    Cachex.put(:cache, id, data, ttl: :timer.hours(1))

    {:noreply, push_navigate(socket, to: "/stacks/nextforge/#{id}")}
  end
end
