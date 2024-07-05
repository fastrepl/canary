defmodule Canary.Sources.Repository do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  attributes do
    uuid_primary_key :id

    attribute :full_name, :string, allow_nil?: false
    attribute :type, :atom, constraints: [one_of: [:github]]
    attribute :github_installation_id, :integer, allow_nil?: true
  end

  identities do
    identity :unique_repository, [:type, :full_name]
  end

  actions do
    defaults [:read, :destroy]

    read :find_github do
      argument :full_name, :string, allow_nil?: false

      get? true
      filter expr(type == :github and full_name == ^arg(:full_name))
    end

    create :create_github do
      argument :full_name, :string, allow_nil?: false
      argument :github_installation_id, :integer, allow_nil?: true

      change set_attribute(:type, :github)
      change set_attribute(:full_name, expr(^arg(:full_name)))
      change set_attribute(:github_installation_id, expr(^arg(:github_installation_id)))
    end
  end

  postgres do
    table "respositories"
    repo Canary.Repo
  end
end
