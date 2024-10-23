defmodule Canary.Accounts.Project do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    simple_notifiers: [Canary.Notifiers.Discord]

  require Ash.Query

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :public_key, :string, allow_nil?: false
    attribute :index_id, :string, allow_nil?: false
  end

  identities do
    identity :unique_public_key, [:public_key]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
    has_many :sources, Canary.Sources.Source
    has_one :insights_config, Canary.Insights.Config
  end

  actions do
    defaults [:read, update: [:name, :public_key]]

    create :create do
      primary? true
      accept [:account_id, :name]

      change fn changeset, _ ->
        key = "cp_" <> String.slice(Ash.UUID.generate(), 0..7)

        changeset
        |> Ash.Changeset.force_change_attribute(:public_key, key)
      end

      change {Canary.Index.Trieve.Changes.CreateDataset, tracking_id_attribute: :index_id}
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      change {Ash.Resource.Change.CascadeDestroy, relationship: :sources, action: :destroy}

      change {Ash.Resource.Change.CascadeDestroy,
              relationship: :insights_config, action: :destroy}

      change {Canary.Index.Trieve.Changes.DeleteDataset, tracking_id_attribute: :index_id}
    end
  end

  aggregates do
    count :num_sources, :sources
  end

  code_interface do
    define :create, args: [:account_id, :name], action: :create
  end

  policies do
    bypass actor_attribute_equals(:super_user, true) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if Canary.Checks.Membership.ProjectCreate
    end

    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "projects"
    repo Canary.Repo
  end
end
