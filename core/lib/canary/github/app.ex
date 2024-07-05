defmodule Canary.Github.App do
  use Ash.Resource,
    domain: Canary.Github,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key :id
    attribute :installation_id, :integer, allow_nil?: false
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :repos, Canary.Github.Repo
  end

  actions do
    defaults [:read, :destroy]

    read :find do
      argument :installation_id, :integer, allow_nil?: false

      get? true
      filter expr(installation_id == ^arg(:installation_id))
    end

    action :delete do
      argument :installation_id, :integer, allow_nil?: false

      run fn %{arguments: %{installation_id: installation_id}}, _ ->
        result =
          __MODULE__
          |> Ash.Query.filter(installation_id == ^installation_id)
          |> Ash.bulk_destroy(:destroy, %{})

        case result do
          %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
          _ -> {:ok, result}
        end
      end
    end

    create :create do
      transaction? true

      argument :installation_id, :integer, allow_nil?: false
      argument :repos, {:array, :string}, allow_nil?: true
      argument :account, :map, allow_nil?: true

      change set_attribute(:installation_id, expr(^arg(:installation_id)))
      change manage_relationship(:account, :account, type: :append)
      change Canary.Github.Changes.CreateRepos
    end

    update :link_account do
      require_atomic? false

      argument :account, :map, allow_nil?: false
      change manage_relationship(:account, :account, type: :append)
    end
  end

  code_interface do
    define :find, args: [:installation_id], action: :find
    define :delete, args: [:installation_id], action: :delete

    define :create,
      args: [:installation_id, {:optional, :repos}, {:optional, :account}],
      action: :create

    define :link_account, args: [:account], action: :link_account
  end

  postgres do
    table "github_apps"
    repo Canary.Repo

    references do
      reference :account, on_delete: :delete
    end
  end
end
