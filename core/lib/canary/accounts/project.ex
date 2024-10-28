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
    attribute :public, :boolean, default: false
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
    defaults [:read, update: [:name, :public_key, :public]]

    create :create do
      primary? true

      accept [:name]
      argument :account_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)

      change fn changeset, _ ->
        account_id = Ash.Changeset.get_argument(changeset, :account_id)

        with {:ok, %{billing: %{membership: %{tier: tier}}}} <-
               Canary.Accounts.Account
               |> Ash.get(account_id, load: [billing: [:membership]]) do
          changeset
          |> Ash.Changeset.force_change_attribute(:public, tier == :admin)
        else
          _ -> changeset
        end
      end

      change fn changeset, _ ->
        key = "cp_" <> String.slice(Ecto.UUID.generate(), 0..7)

        changeset
        |> Ash.Changeset.force_change_attribute(:public_key, key)
      end

      change {Canary.Index.Trieve.Changes.CreateDataset, tracking_id_attribute: :index_id}
    end

    update :transfer do
      require_atomic? false
      argument :account_id, :uuid, allow_nil?: false

      change set_attribute(:public, false)
      change manage_relationship(:account_id, :account, type: :append_and_remove)
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
