defmodule Canary.Insights.Config do
  use Ash.Resource,
    domain: Canary.Insights,
    data_layer: AshPostgres.DataLayer

  alias Canary.Insights.QueryAlias

  attributes do
    uuid_primary_key :id

    attribute :aliases, {:array, QueryAlias}, default: []
  end

  relationships do
    belongs_to :project, Canary.Accounts.Project, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: [:aliases, :project_id], update: [:aliases]]
  end

  postgres do
    table "insights_configs"
    repo Canary.Repo

    references do
      reference :project, deferrable: :initially
    end
  end
end
