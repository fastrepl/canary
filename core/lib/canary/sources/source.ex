defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :account_id, :uuid do
      allow_nil? false
    end

    attribute :type, :atom, constraints: [one_of: [:web]]

    attribute :web_base_url, :string
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :documents, Canary.Sources.Document
  end

  actions do
    defaults [:read]

    create :create_web do
      argument :account_id, :uuid do
        allow_nil? false
      end

      argument :web_base_url, :string do
        allow_nil? false
      end

      change set_attribute(:account_id, expr(^arg(:account_id)))
      change set_attribute(:web_base_url, expr(^arg(:web_base_url)))
      change set_attribute(:type, :web)
    end
  end

  aggregates do
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
