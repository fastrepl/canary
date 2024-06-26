defmodule Canary.Clients.Client do
  use Ash.Resource,
    domain: Canary.Clients,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :account_id, :uuid do
      allow_nil? false
    end

    attribute :type, :atom, constraints: [one_of: [:web, :discord]]

    attribute :web_base_url, :string
    attribute :web_public_key, :string

    attribute :discord_server_id, :integer
    attribute :discord_channel_id, :integer
  end

  identities do
    identity :unique_web, [:web_base_url, :web_public_key]
    identity :unique_discord, [:discord_server_id, :discord_channel_id]
  end

  actions do
    defaults [:read, :destroy]

    read :find_discord do
      argument :discord_server_id, :integer, allow_nil?: false
      argument :discord_channel_id, :integer, allow_nil?: false

      filter expr(
               discord_server_id == ^arg(:discord_server_id) and
                 discord_channel_id == ^arg(:discord_channel_id)
             )

      prepare build(load: [:sources])
    end

    create :create_web do
      argument :account_id, :uuid do
        allow_nil? false
      end

      argument :web_base_url, :string do
        allow_nil? false
      end

      change set_attribute(:type, :web)
      change set_attribute(:account_id, expr(^arg(:account_id)))
      change set_attribute(:web_base_url, expr(^arg(:web_base_url)))
      change set_attribute(:web_public_key, &Ash.UUID.generate/0)
    end

    create :create_discord do
      argument :account_id, :uuid do
        allow_nil? false
      end

      argument :discord_server_id, :integer do
        allow_nil? false
      end

      argument :discord_channel_id, :integer do
        allow_nil? false
      end

      change set_attribute(:type, :discord)
      change set_attribute(:account_id, expr(^arg(:account_id)))
      change set_attribute(:discord_server_id, expr(^arg(:discord_server_id)))
      change set_attribute(:discord_channel_id, expr(^arg(:discord_channel_id)))
    end

    update :add_sources do
      require_atomic? false

      argument :sources, {:array, :map}, allow_nil?: true
      change manage_relationship(:sources, type: :append)
    end

    update :remove_sources do
      require_atomic? false

      argument :sources, {:array, :map}, allow_nil?: true
      change manage_relationship(:sources, type: :remove)
    end
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account

    many_to_many :sources, Canary.Sources.Source do
      through Canary.Clients.ClientSource
    end
  end

  postgres do
    table "clients"
    repo Canary.Repo
  end
end
