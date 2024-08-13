defmodule CanaryWeb.Layouts do
  use CanaryWeb, :html

  embed_templates "layouts/*"

  attr :active_tab, :any, default: nil
  attr :current_user, :any, default: nil
  attr :current_account, :any, default: nil

  def side_menu(assigns) do
    ~H"""
    <aside class="drawer-side z-10">
      <label for="canary-drawer" class="drawer-overlay"></label>
      <nav class="flex min-h-screen w-52 flex-col gap-2 overflow-y-auto bg-base-200 px-6 pt-10 pb-4">
        <div class="mx-4 flex items-center gap-2 font-black">
          <button class="text-lg">🐤</button>
          <.link navigate={~p"/"}>Canary</.link>
        </div>

        <ul class="menu">
          <li>
            <.link class={if @active_tab == :home, do: "active"} navigate={~p"/"}>
              <span class={[
                "h-4 w-4",
                if(@active_tab == :home,
                  do: "hero-home-solid",
                  else: "hero-home"
                )
              ]} />
              <span>Home</span>
            </.link>
          </li>

          <li>
            <.link class={if @active_tab == :source, do: "active"} navigate={~p"/source"}>
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

          <%!-- <li>
            <.link class={if @active_tab == :editor, do: "active"} navigate={~p"/editor"}>
              <span class={[
                "h-4 w-4",
                if(@active_tab == :editor,
                  do: "hero-pencil-square-solid",
                  else: "hero-pencil-square"
                )
              ]} />
              <span>Editor</span>
            </.link>
          </li>
          <li>
            <.link class={if @active_tab == :interactions, do: "active"} navigate={~p"/interactions"}>
              <span class={[
                "h-4 w-4",
                if(@active_tab == :interactions,
                  do: "hero-megaphone-solid",
                  else: "hero-megaphone"
                )
              ]} />
              <span>Interactions</span>
            </.link>
          </li> --%>
          <li>
            <.link class={if @active_tab == :settings, do: "active"} navigate={~p"/settings"}>
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

        <div class="flex flex-row items-center justify-between mt-auto">
          <select class="select select-bordered select-sm w-[120px]">
            <option selected>
              <%= @current_account.name %>
            </option>
          </select>

          <div class="dropdown dropdown-top dropdown-end">
            <div tabindex="0" role="button" class="avatar placeholder">
              <div class="bg-neutral text-neutral-content w-8 rounded-full">
                <span class="text-md">
                  <%= @current_user.email |> to_string() |> String.at(0) |> String.upcase() %>
                </span>
              </div>
            </div>
            <ul
              tabindex="0"
              class="dropdown-content menu bg-base-100 rounded-box z-[1] w-24 p-0 shadow"
            >
              <li><.link href="/sign-out">Log out</.link></li>
            </ul>
          </div>
        </div>
      </nav>
    </aside>
    """
  end

  slot :inner_block

  def content_header(assigns) do
    ~H"""
    <header class="flex items-center">
      <label for="canary-drawer" class="btn btn-square btn-ghost drawer-button lg:hidden">
        <span class="hero-bars-3-solid h-5 w-5" />
      </label>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end
end
