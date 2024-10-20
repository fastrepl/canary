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
    attribute :selected, :boolean, allow_nil?: false, default: false
    attribute :public_key, :string, allow_nil?: false
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
    defaults [:read]

    create :create do
      primary? true
      accept [:account_id, :name]

      change fn changeset, _ ->
        key = "cp_" <> String.slice(Ash.UUID.generate(), 0..7)

        changeset
        |> Ash.Changeset.force_change_attribute(:public_key, key)
      end
    end

    update :update do
      primary? true
      accept [:name, :selected, :public_key]
    end

    update :select do
      argument :account_id, :uuid, allow_nil?: false
      require_atomic? false

      change fn changeset, _ ->
        account_id = Ash.Changeset.get_argument(changeset, :account_id)

        case __MODULE__
             |> Ash.Query.filter(account_id == ^account_id)
             |> Ash.bulk_update(:update, %{selected: false}, return_errors?: true) do
          %Ash.BulkResult{status: :success} -> changeset
          %Ash.BulkResult{errors: errors} -> changeset |> Ash.Changeset.add_error(errors)
        end
      end

      change set_attribute(:selected, true)
    end

    destroy :destroy do
      primary? true
      change {Ash.Resource.Change.CascadeDestroy, relationship: :sources, action: :destroy}

      change {Ash.Resource.Change.CascadeDestroy,
              relationship: :insights_config, action: :destroy}
    end
  end

  aggregates do
    count :num_sources, :sources
  end

  code_interface do
    define :create, args: [:account_id, :name], action: :create
    define :select, args: [:account_id], action: :select
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
