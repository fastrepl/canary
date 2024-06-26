defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    attribute :account_id, :uuid, allow_nil?: false

    attribute :name, :string, allow_nil?: false
    attribute :type, :atom, constraints: [one_of: [:web]]

    attribute :web_base_url, :string
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
      argument :name, :string, allow_nil?: false
      argument :account, :map, allow_nil?: false
      argument :web_base_url, :string, allow_nil?: false

      change set_attribute(:type, :web)
      change set_attribute(:name, expr(^arg(:name)))
      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:web_base_url, expr(^arg(:web_base_url)))
      change load(:updated_at)
    end
  end

  aggregates do
    count :num_documents, :documents do
      filter expr(is_nil(content_embedding) == false)
    end

    max :updated_at, :documents, :updated_at do
      # this aggregation will be used for removing outdated documents.
      # since document without embedding is not searchable yet,
      # it should not affect the freshness of other documents.
      filter expr(is_nil(content_embedding) == false)
    end
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
