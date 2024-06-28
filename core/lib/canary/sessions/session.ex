defmodule Canary.Sessions.Session do
  use Ash.Resource,
    domain: Canary.Sessions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :discord_id, :integer, allow_nil?: true
    attribute :web_id, :string, allow_nil?: true
  end

  identities do
    identity :unique_discord, [:account_id, :discord_id]
    identity :unique_web, [:account_id, :web_id]
  end

  actions do
    defaults [:read]

    read :find_with_discord do
      argument :account_id, :uuid, allow_nil?: false
      argument :discord_id, :integer, allow_nil?: false

      get? true
      filter expr(account_id == ^arg(:account_id) and discord_id == ^arg(:discord_id))
      prepare build(load: [:account, :messages])
    end

    read :find_with_web do
      argument :account_id, :uuid, allow_nil?: false
      argument :web_id, :string, allow_nil?: false

      get? true
      filter expr(account_id == ^arg(:account_id) and web_id == ^arg(:web_id))
      prepare build(load: [:account, :messages])
    end

    create :create_with_discord do
      argument :account, :map, allow_nil?: false
      argument :discord_id, :integer, allow_nil?: false

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:discord_id, expr(^arg(:discord_id)))
      change load [:account, :messages]
    end

    create :create_with_web do
      argument :account, :map, allow_nil?: false
      argument :web_id, :string, allow_nil?: false

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:web_id, expr(^arg(:web_id)))
      change load [:account, :messages]
    end
  end

  code_interface do
    define :create_with_discord,
      args: [:account, :discord_id],
      action: :create_with_discord

    define :create_with_web,
      args: [:account, :web_id],
      action: :create_with_web

    define :find_with_discord, args: [:account_id, :discord_id], action: :find_with_discord
    define :find_with_web, args: [:account_id, :web_id], action: :find_with_web
  end

  aggregates do
    min :started_at, :messages, :created_at
    max :ended_at, :messages, :created_at
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :messages, Canary.Sessions.Message
  end

  postgres do
    table "sessions"
    repo Canary.Repo
  end
end
