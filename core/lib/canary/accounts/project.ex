defmodule Canary.Accounts.Project do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    simple_notifiers: [Canary.Notifiers.Discord]

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :public_key, :string, allow_nil?: false
  end

  identities do
    identity :unique_public_key, [:public_key]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
    has_many :sources, Canary.Sources.Source
  end

  actions do
    defaults [:read, :destroy]

    read :find_by_public_key do
      get? true
      argument :public_key, :string, allow_nil?: false
      filter expr(public_key == ^arg(:public_key))
    end

    create :create do
      primary? true
      accept [:account_id, :name]

      change fn changeset, _ ->
        key = "cp" <> String.slice(Ash.UUID.generate(), 0..7)

        changeset
        |> Ash.Changeset.force_change_attribute(:public_key, key)
      end
    end
  end

  code_interface do
    define :find_by_public_key, args: [:public_key], action: :find_by_public_key
    define :create, args: [:account_id, :name], action: :create
  end

  postgres do
    table "projects"
    repo Canary.Repo
  end
end
