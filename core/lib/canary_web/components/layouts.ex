defmodule CanaryWeb.Layouts do
  use CanaryWeb, :html
  alias PrimerLive.Component, as: Primer

  embed_templates "layouts/*"

  attr :projects, :any, default: []
  attr :current_project, :any, default: nil

  def app_select_project(assigns) do
    ~H"""
    <form phx-change="project-change">
      <Primer.select
        name="current-project"
        options={Enum.map(@projects, & &1.name)}
        selected={@current_project.name}
        is_full_width
      />
    </form>
    """
  end

  attr :active_tab, :any, default: nil
  attr :current_account, :any, default: nil
  attr :current_project, :any, default: nil

  def app_side_menu(assigns) do
    ~H"""
    <nav class="flex flex-1 flex-col">
      <ul role="list" class="flex flex-1 flex-col gap-y-7">
        <li>
          <ul role="list" class="-mx-2 space-y-1">
            <li
              :for={
                %{
                  url: url,
                  name: name,
                  tab: tab,
                  icon_inactive: icon_inactive,
                  icon_active: icon_active
                } <- [
                  %{
                    url: "/",
                    name: "Home",
                    tab: :home,
                    icon_inactive: "hero-document",
                    icon_active: "hero-home-solid"
                  },
                  %{
                    url: "/source",
                    name: "Source",
                    tab: :source,
                    icon_inactive: "hero-document",
                    icon_active: "hero-document-solid"
                  },
                  %{
                    url: "/insight",
                    name: "Insight",
                    tab: :insight,
                    icon_inactive: "hero-eye",
                    icon_active: "hero-eye-solid"
                  },
                  %{
                    url: "/settings",
                    name: "Settings",
                    tab: :settings,
                    icon_inactive: "hero-cog-6-tooth",
                    icon_active: "hero-cog-6-tooth-solid"
                  }
                ]
              }
              class={[if(@active_tab == tab, do: "bg-blue-50 text-blue-800 rounded-md", else: "")]}
            >
              <.link
                navigate={url}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == tab, do: icon_active, else: icon_inactive)
                ]} />
                <span><%= name %></span>
              </.link>
            </li>
          </ul>
        </li>

        <li class="mt-auto mb-4 flex flex-row items-center justify-between">
          <.app_select_project
            projects={@current_account.projects}
            current_project={@current_project}
          />
          <.link navigate={~p"/sign-out"}>Logout</.link>
        </li>
      </ul>
    </nav>
    """
  end

  attr :active_tab, :any, default: nil

  def settings_side_menu(assigns) do
    ~H"""
    <nav class="flex flex-1 flex-col">
      <ul role="list" class="flex flex-1 flex-col gap-y-7">
        <li>
          <ul role="list" class="-mx-2 space-y-1">
            <li class="mb-4">
              <.link navigate={~p"/"}>
                <span>Back to home</span>
              </.link>
            </li>
            <li
              :for={
                %{
                  url: url,
                  name: name,
                  tab: tab,
                  icon_inactive: icon_inactive,
                  icon_active: icon_active
                } <- [
                  %{
                    url: "/settings/account",
                    name: "Account",
                    tab: :account,
                    icon_inactive: "hero-cog-6-tooth",
                    icon_active: "hero-cog-6-tooth-solid"
                  },
                  %{
                    url: "/settings/projects",
                    name: "Projects",
                    tab: :projects,
                    icon_inactive: "hero-cog-6-tooth",
                    icon_active: "hero-cog-6-tooth-solid"
                  },
                  %{
                    url: "/settings/members",
                    name: "Members",
                    tab: :members,
                    icon_inactive: "hero-user-group",
                    icon_active: "hero-user-group-solid"
                  },
                  if(Application.get_env(:canary, :self_host)) do
                    nil
                  else
                    %{
                      url: "/settings/billing",
                      name: "Billing",
                      tab: :billing,
                      icon_inactive: "hero-credit-card",
                      icon_active: "hero-credit-card-solid"
                    }
                  end
                ]
              }
              class={[if(@active_tab == tab, do: "bg-blue-50 text-blue-800 rounded-md", else: "")]}
            >
              <.link
                navigate={url}
                class="flex flex-row items-center gap-2 font-semibold hover:no-underline hover:bg-gray-100 rounded-md p-2"
              >
                <span class={[
                  "h-4 w-4",
                  if(@active_tab == tab, do: icon_active, else: icon_inactive)
                ]} />
                <span><%= name %></span>
              </.link>
            </li>
          </ul>
        </li>
      </ul>
    </nav>
    """
  end
end
