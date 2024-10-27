defmodule Canary.Workers.QueryAliases do
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Canary.Accounts.Project

  @impl true
  def perform(%Oban.Job{args: %{"project_id" => project_id}}) do
    {:ok, %{insights_config: config}} = Ash.get(Project, project_id, load: [:insights_config])

    {:ok, analytics_result} =
      Canary.Analytics.query(:search_breakdown, %{project_id: project_id, n: 100, days: 120})

    {:ok, completion_result} =
      Canary.AI.chat(%{
        model: Application.fetch_env!(:canary, :general_model),
        messages: [
          %{role: "system", content: "Only output JSON that strictly follows the schema."},
          %{
            role: "user",
            content: """
            ---
            #{Jason.encode!(analytics_result, pretty: true)}
            ---

            Above are analytics on quries user typed in the search bar.
            Some of them are just partial queries performed while typing, and some of them are full queries but similar.
            Write down aliases if they can be combined. Take extra care on partial queries.

            For example, if we have "examp", "example" and "exam" in the quries list, we can combine them into:
            name: "example",
            members: ["example", "examp", "exam"]

            Each item in "members" must be picked from the above queries, without any extra text.
            Length of "members" should be more than 1, otherwise, there's no point to create an alias.

            This is existing aliases. You can remove, add, or edit it, but should mostly follow the intention & keep it.
            ---
            #{Jason.encode!(config, pretty: true)}
            ---
            """
          }
        ],
        temperature: 0,
        max_tokens: 3000,
        response_format: %{
          type: "json_schema",
          json_schema: %{
            name: "Aliases",
            strict: true,
            schema: %{
              type: "object",
              properties: %{
                aliases: %{
                  type: "array",
                  items: %{
                    type: "object",
                    properties: %{
                      name: %{type: "string"},
                      members: %{
                        type: "array",
                        items: %{type: "string"}
                      }
                    },
                    required: ["name", "members"],
                    additionalProperties: false
                  }
                }
              },
              required: ["aliases"],
              additionalProperties: false
            }
          }
        }
      })

    %{"aliases" => aliases} = Jason.decode!(completion_result)

    if is_nil(config) do
      Canary.Insights.Config
      |> Ash.Changeset.for_create(:create, %{aliases: aliases, project_id: project_id})
      |> Ash.create()
    else
      config
      |> Ash.Changeset.for_update(:update, %{aliases: aliases})
      |> Ash.update()
    end

    :ok
  end
end
