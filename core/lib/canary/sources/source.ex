defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :type, :atom, constraints: [one_of: [:web]], allow_nil?: false

    attribute :web_url_base, :string, allow_nil?: true
    attribute :web_url_include_patterns, {:array, :string}, allow_nil?: true
    attribute :web_url_exclude_patterns, {:array, :string}, allow_nil?: true
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :documents, Canary.Sources.Document
  end

  aggregates do
    count :num_documents, :documents
    max :last_updated, :documents, :created_at
  end

  actions do
    defaults [:destroy, update: [:web_url_include_patterns, :web_url_exclude_patterns]]

    read :read do
      primary? true
      prepare build(load: [:num_documents, :last_updated])
    end

    create :create do
      primary? true

      argument :account, :map, allow_nil?: false
      argument :web_url_base, :string, allow_nil?: false
      argument :web_url_include_patterns, {:array, :string}, default: []
      argument :web_url_exclude_patterns, {:array, :string}, default: []

      change set_attribute(:type, :web)
      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:web_url_base, arg(:web_url_base))
      change set_attribute(:web_url_include_patterns, arg(:web_url_include_patterns))
      change set_attribute(:web_url_exclude_patterns, arg(:web_url_exclude_patterns))
    end
  end

  code_interface do
    define :create, args: [:account, :web_url_base], action: :create
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
