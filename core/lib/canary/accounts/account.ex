defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    simple_notifiers: [Canary.Notifiers.Discord]

  require Ash.Query

  attributes do
    uuid_primary_key :id
    attribute :super_user, :boolean, default: false
    attribute :name, :string, allow_nil?: false
    attribute :selected, :boolean, allow_nil?: false, default: false
  end

  relationships do
    has_one :billing, Canary.Accounts.Billing
    has_many :projects, Canary.Accounts.Project

    has_one :owner, Canary.Accounts.User

    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end
  end

  actions do
    defaults [:read, :destroy, update: [:name, :super_user]]

    create :create do
      primary? true
      accept [:name]
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :owner, type: :append)
      change manage_relationship(:user_id, :users, type: :append)
    end

    update :add_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :append)
    end

    update :remove_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :remove)
    end

    update :select do
      argument :user_id, :uuid, allow_nil?: false
      require_atomic? false

      change fn changeset, _ ->
        user_id = Ash.Changeset.get_argument(changeset, :user_id)

        case __MODULE__
             |> Ash.Query.filter(user_id == ^user_id)
             |> Ash.bulk_update(:update, %{selected: false}, return_errors?: true) do
          %Ash.BulkResult{status: :success} -> changeset
          %Ash.BulkResult{errors: errors} -> changeset |> Ash.Changeset.add_error(errors)
        end
      end

      change set_attribute(:selected, true)
    end
  end

  changes do
    change Canary.Accounts.Changes.InitBilling, on: [:create]
  end

  aggregates do
    count :num_projects, :projects
    count :num_members, :users
  end

  code_interface do
    define :select, args: [:user_id], action: :select
    define :add_member, args: [:user_id], action: :add_member
    define :remove_member, args: [:user_id], action: :remove_member
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end
