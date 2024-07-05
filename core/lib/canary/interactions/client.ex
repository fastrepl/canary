defmodule Canary.Interactions.Client do
  use Ash.Resource,
    domain: Canary.Interactions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :name, :string, allow_nil?: false
    attribute :type, :atom, constraints: [one_of: [:discord]], allow_nil?: false

    attribute :discord_server_id, :integer, allow_nil?: true
    attribute :discord_channel_id, :integer, allow_nil?: true
  end

  identities do
    identity :unique_client, [:source_id, :name]
    identity :unique_discord, [:discord_server_id, :discord_channel_id]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read, :destroy]

    read :find_discord do
      argument :discord_server_id, :integer, allow_nil?: false
      argument :discord_channel_id, :integer, allow_nil?: false

      filter expr(type == :discord)
      filter expr(discord_server_id == ^arg(:discord_server_id))
      filter expr(discord_channel_id == ^arg(:discord_channel_id))

      get? true
      prepare build(load: [:source])
    end

    create :create_discord do
      argument :source, :map, allow_nil?: false
      argument :name, :string, allow_nil?: false

      argument :discord_server_id, :integer, allow_nil?: false
      argument :discord_channel_id, :integer, allow_nil?: false

      change set_attribute(:type, :discord)
      change set_attribute(:name, expr(^arg(:name)))
      change manage_relationship(:source, :source, type: :append)
      change set_attribute(:discord_server_id, expr(^arg(:discord_server_id)))
      change set_attribute(:discord_channel_id, expr(^arg(:discord_channel_id)))
    end
  end

  code_interface do
    define :find_discord,
      args: [:discord_server_id, :discord_channel_id],
      action: :find_discord

    define :create_discord,
      args: [:source, :name, :discord_server_id, :discord_channel_id],
      action: :create_discord
  end

  postgres do
    table "clients"
    repo Canary.Repo

    references do
      reference :source, on_delete: :delete
    end
  end
end
