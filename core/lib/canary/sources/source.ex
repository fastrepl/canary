defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :type, :atom, constraints: [one_of: [:web]], allow_nil?: false
    attribute :web_base_url, :string, allow_nil?: false
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :documents, Canary.Sources.Document
  end

  aggregates do
    count :num_documents, :documents
    max :last_updated, :documents, :created_at
    list :summaries, :documents, :summary
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:num_documents, :last_updated])
    end

    create :create_web do
      argument :account, :map, allow_nil?: false
      argument :web_base_url, :string, allow_nil?: false

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:type, :web)
      change set_attribute(:web_base_url, expr(^arg(:web_base_url)))
    end
  end

  code_interface do
    define :create_web, args: [:account, :web_base_url], action: :create_web
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
