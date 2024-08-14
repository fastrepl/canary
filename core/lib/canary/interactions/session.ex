defmodule Canary.Interactions.Session do
  use Ash.Resource,
    domain: Canary.Interactions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :type, :atom, constraints: [one_of: [:discord, :web]], allow_nil?: false
    attribute :web_session_id, :uuid, allow_nil?: true
    attribute :discord_thread_id, :integer, allow_nil?: true
  end

  identities do
    identity :web_session_identity, [:account_id, :type, :web_session_id]
    identity :discord_thread_identity, [:account_id, :type, :discord_thread_id]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
    has_many :messages, Canary.Interactions.Message
  end

  actions do
    defaults [:read]

    read :find_with_web do
      argument :account_id, :uuid, allow_nil?: false
      argument :web_session_id, :uuid, allow_nil?: false

      filter expr(type == :web)
      filter expr(account_id == ^arg(:account_id))
      filter expr(web_session_id == ^arg(:web_session_id))

      get? true
      prepare build(load: [:account, :messages])
    end

    read :find_with_discord do
      argument :account_id, :uuid, allow_nil?: false
      argument :discord_thread_id, :integer, allow_nil?: false

      filter expr(type == :discord)
      filter expr(account_id == ^arg(:account_id))
      filter expr(discord_thread_id == ^arg(:discord_thread_id))

      get? true
      prepare build(load: [:account, :messages])
    end


    create :create_with_web do
      argument :account_id, :uuid, allow_nil?: false
      argument :web_session_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)
      change set_attribute(:type, :web)
      change set_attribute(:web_session_id, expr(^arg(:web_session_id)))
      change load [:account, :messages]
    end

    create :create_with_discord do
      argument :account_id, :uuid, allow_nil?: false
      argument :discord_thread_id, :integer, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)
      change set_attribute(:type, :discord)
      change set_attribute(:discord_thread_id, expr(^arg(:discord_thread_id)))
      change load [:account, :messages]
    end

  end

  code_interface do
    define :create_with_web, args: [:account_id, :web_session_id], action: :create_with_web
    define :create_with_discord, args: [:account_id, :discord_thread_id], action: :create_with_discord

    define :find_with_web, args: [:account_id, :web_session_id], action: :find_with_web
    define :find_with_discord, args: [:account_id, :discord_thread_id], action: :find_with_discord
  end

  aggregates do
    min :started_at, :messages, :created_at
    max :ended_at, :messages, :created_at
  end

  postgres do
    table "sessions"
    repo Canary.Repo
  end
end
