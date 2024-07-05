defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  @supported_docs [:docusaurus]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :type, :atom, constraints: [one_of: @supported_docs], allow_nil?: false

    attribute :base_url, :string, allow_nil?: false
    attribute :base_path, :string, allow_nil?: false
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_one :github_repo, Canary.Github.Repo
    has_many :documents, Canary.Sources.Document
    has_many :clients, Canary.Interactions.Client
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:num_documents])
    end

    create :create do
      argument :account, :map, allow_nil?: false
      argument :type, :atom, constraints: [one_of: @supported_docs], allow_nil?: false
      argument :base_url, :string, allow_nil?: false
      argument :base_path, :string, allow_nil?: false

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:base_path, expr(^arg(:base_path)))
      change set_attribute(:type, expr(^arg(:type)))
      change set_attribute(:base_url, expr(^arg(:base_url)))
      change set_attribute(:base_path, expr(^arg(:base_path)))
    end
  end

  aggregates do
    count :num_documents, :documents
  end

  json_api do
    type "source"

    routes do
      get(:read, route: "sources/:id")
      post(:create, route: "sources/web")
    end
  end

  code_interface do
    define :create, args: [:account, :type, :base_url, :base_path], action: :create
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
