defmodule CanaryWeb.Layouts do
  use CanaryWeb, :html

  embed_templates "layouts/*"

  attr :active_tab, :any, default: nil
  attr :current_user, :any, default: nil
  attr :current_account, :any, default: nil

  def side_menu(assigns) do
    ~H"""
    <nav class="flex flex-1 flex-col">
      <ul role="list" class="flex flex-1 flex-col gap-y-7">
        <li>
          <ul role="list" class="-mx-2 space-y-1">
            <li>
              <.link
                navigate={~p"/"}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == :home,
                    do: "hero-home-solid",
                    else: "hero-document"
                  )
                ]} />
                <span>Home</span>
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/source"}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == :source,
                    do: "hero-document-solid",
                    else: "hero-document"
                  )
                ]} />
                <span>Source</span>
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/insights"}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == :insights,
                    do: "hero-light-bulb-solid",
                    else: "hero-light-bulb"
                  )
                ]} />
                <span>Insights</span>
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/settings"}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == :settings,
                    do: "hero-cog-6-tooth-solid",
                    else: "hero-cog-6-tooth"
                  )
                ]} />
                <span>Settings</span>
              </.link>
            </li>
          </ul>
        </li>

        <li class="mt-auto mb-4">
          <.link navigate={~p"/sign-out"}>
            Logout
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
