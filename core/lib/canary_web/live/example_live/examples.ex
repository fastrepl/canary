defmodule CanaryWeb.ExampleLive.Examples do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.live_component
        :for={example <- @examples}
        id={"example-#{example.name}"}
        module={CanaryWeb.ExampleLive.Example}
        current_project={@current_project}
        example={example}
      />
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    has_webpage =
      assigns.current_project.sources
      |> Enum.any?(&(&1.config.type == :webpage))

    has_github =
      assigns.current_project.sources
      |> Enum.any?(&(&1.config.type in [:github_issue, :github_discussion]))

    tags =
      assigns.current_project.sources
      |> Enum.filter(&(&1.config.type == :webpage))
      |> Enum.flat_map(& &1.config.value.tag_definitions)
      |> Enum.map(& &1.name)
      |> Enum.uniq()
      |> Enum.join(",")

    tabs = [
      %{
        name: "Docs",
        pattern: "**/*",
        options: %{ignore: "**/github.com/**"}
      },
      %{
        name: "Github",
        pattern: "**/github.com/**"
      }
    ]

    examples =
      [
        %{
          name: "Simple search",
          description:
            "Blazing fast fulltext search + semantic/hybrid search for longer, question-like queries.",
          code: """
          <canary-root query="#{assigns.current_project.name}">
            <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
              <canary-modal transition>
                <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                  <canary-content slot="content">
                    <canary-input slot="input" autofocus></canary-input>
                    <canary-search slot="mode"> // [!code highlight]
                      <canary-search-results slot="body"></canary-search-results> // [!code highlight]
                    </canary-search> // [!code highlight]
                  </canary-content>
              </canary-modal>
            </canary-provider-cloud>
          </canary-root>
          """
        },
        %{
          name: "Custom search bar",
          description: "Everything is customizable. It's web-component.",
          code: """
          <canary-root query="#{assigns.current_project.name}">
            <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
              <canary-modal transition>
                <!-- <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar> --> // [!code --]
                <button slot="trigger" class="border max-w-[400px] p-4 bg-gray-100 hover:bg-gray-200">Click this!</button> // [!code ++]
                  <canary-content slot="content">
                    <canary-input slot="input" autofocus></canary-input>
                    <canary-search slot="mode">
                      <canary-search-results slot="body"></canary-search-results>
                    </canary-search>
                  </canary-content>
              </canary-modal>
            </canary-provider-cloud>
          </canary-root>
          """
        },
        if(has_webpage and has_github,
          do: %{
            name: "Search with tabs",
            description:
              "Can create any number of tabs using glob patterns. e.g. Docs / Blog / GitHub / API / etc.",
            code: """
            <canary-root query="#{assigns.current_project.name}">
              <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
                <canary-modal transition>
                  <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                    <canary-content slot="content">
                      <canary-input slot="input" autofocus></canary-input>
                      <canary-search slot="mode">
                        <canary-filter-tabs-glob slot="head" tabs='#{Jason.encode!(tabs)}'></canary-filter-tabs-glob> // [!code ++]
                        <canary-search-results slot="body"></canary-search-results>
                      </canary-search>
                    </canary-content>
                </canary-modal>
              </canary-provider-cloud>
            </canary-root>
            """
          },
          else: nil
        ),
        if(tags !== "",
          do: %{
            name: "Search with tags",
            description: "Can split results based on selected tags.",
            code: """
            <canary-root query="#{assigns.current_project.name}">
              <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
                <canary-modal transition>
                  <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                    <canary-content slot="content">
                      <canary-filter-tags slot="head" tags="#{tags}"></canary-filter-tags> // [!code ++]
                      <canary-input slot="input" autofocus></canary-input>
                      <canary-search slot="mode">
                        <canary-search-results slot="body"></canary-search-results>
                      </canary-search>
                    </canary-content>
                </canary-modal>
              </canary-provider-cloud>
            </canary-root>
            """
          },
          else: nil
        ),
        cond do
          has_webpage and has_github and tags != "" ->
            %{
              name: "Search with Ask AI",
              paid: true,
              description: "Type longer question, and press tab to run 'Ask AI'.",
              code: """
              <canary-root query="why use #{assigns.current_project.name}?">
                <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
                  <canary-modal transition>
                    <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                      <canary-content slot="content">
                        <canary-filter-tags slot="head" tags="#{tags}"></canary-filter-tags>
                        <canary-input slot="input" autofocus></canary-input>
                        <canary-search slot="mode">
                          <canary-filter-tabs-glob slot="head" tabs='#{Jason.encode!(tabs)}'></canary-filter-tabs-glob>
                          <canary-search-results slot="body"></canary-search-results>
                        </canary-search>
                        <canary-ask slot="mode"> // [!code ++]
                          <canary-ask-results slot="body"></canary-ask-results> // [!code ++]
                        </canary-ask> // [!code ++]
                      </canary-content>
                  </canary-modal>
                </canary-provider-cloud>
              </canary-root>
              """
            }

          has_webpage and has_github and tags == "" ->
            %{
              name: "Search with Ask AI",
              paid: true,
              description: "Type longer question, and press tab to run 'Ask AI'.",
              code: """
              <canary-root query="why use #{assigns.current_project.name}?">
                <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
                  <canary-modal transition>
                    <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                      <canary-content slot="content">
                        <canary-input slot="input" autofocus></canary-input>
                        <canary-search slot="mode">
                          <canary-filter-tabs-glob slot="head" tabs='#{Jason.encode!(tabs)}'></canary-filter-tabs-glob>
                          <canary-search-results slot="body"></canary-search-results>
                        </canary-search>
                        <canary-ask slot="mode"> // [!code ++]
                          <canary-ask-results slot="body"></canary-ask-results> // [!code ++]
                        </canary-ask> // [!code ++]
                      </canary-content>
                  </canary-modal>
                </canary-provider-cloud>
              </canary-root>
              """
            }

          true ->
            %{
              name: "Search with Ask AI",
              paid: true,
              description: "Type longer question, and press tab to run 'Ask AI'.",
              code: """
              <canary-root query="why use #{assigns.current_project.name}?">
                <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
                  <canary-modal transition>
                    <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                      <canary-content slot="content">
                        <canary-input slot="input" autofocus></canary-input>
                        <canary-search slot="mode">
                          <canary-search-results slot="body"></canary-search-results>
                        </canary-search>
                        <canary-ask slot="mode"> // [!code ++]
                          <canary-ask-results slot="body"></canary-ask-results> // [!code ++]
                        </canary-ask> // [!code ++]
                      </canary-content>
                  </canary-modal>
                </canary-provider-cloud>
              </canary-root>
              """
            }
        end,
        %{
          name: "Render anything in the footer",
          code: """
          <canary-root query="thank you for the shout-out!">
            <canary-provider-cloud project-key="#{assigns.current_project.public_key}" api-base="#{CanaryWeb.Endpoint.url()}">
              <canary-modal transition>
                <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                  <canary-content slot="content">
                    <canary-input slot="input" autofocus></canary-input>
                    <canary-search slot="mode">
                      <canary-search-results slot="body"></canary-search-results>
                    </canary-search>
                    <canary-footer slot="footer"></canary-footer> // [!code ++]
                  </canary-content>
              </canary-modal>
            </canary-provider-cloud>
          </canary-root>
          """
        }
      ]
      |> Enum.reject(&is_nil/1)

    socket =
      socket
      |> assign(assigns)
      |> assign(:examples, examples)

    {:ok, socket}
  end
end
