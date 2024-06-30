defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :account_id, :uuid, allow_nil?: false

    attribute :name, :string, allow_nil?: false, public?: true
    attribute :type, :atom, constraints: [one_of: [:generic, :web]], public?: true

    attribute :web_base_url, :string, public?: true
  end

  identities do
    identity :unique_source, [:account_id, :name]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :documents, Canary.Sources.Document
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:updated_at, :num_documents])
    end

    create :create_web do
      argument :account, :map, allow_nil?: false
      argument :name, :string, allow_nil?: false
      argument :web_base_url, :string, allow_nil?: false

      change set_attribute(:type, :web)
      change set_attribute(:name, expr(^arg(:name)))
      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:web_base_url, expr(^arg(:web_base_url)))
      change load(:updated_at)
    end
  end

  aggregates do
    max :updated_at, :documents, :created_at
    count :num_documents, :documents
  end

  code_interface do
    define :create_web, args: [:account, :name, :web_base_url], action: :create_web
  end

  json_api do
    type "source"

    routes do
      get(:read, route: "sources/:id")
      post(:create_web, route: "sources/web")
    end
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
