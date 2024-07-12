defmodule Canary.Interactions.Client do
  use Ash.Resource,
    domain: Canary.Interactions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    attribute :type, :atom, constraints: [one_of: [:web, :discord]], allow_nil?: false

    attribute :web_host_url, :string, allow_nil?: true
    attribute :web_public_key, :string, allow_nil?: true

    attribute :discord_server_id, :integer, allow_nil?: true
    attribute :discord_channel_id, :integer, allow_nil?: true
  end

  identities do
    identity :unique_web, [:web_public_key]
    identity :unique_discord, [:discord_server_id, :discord_channel_id]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false

    many_to_many :sources, Canary.Sources.Source do
      through Canary.Interactions.ClientSource
    end
  end

  actions do
    defaults [:read, :destroy]

    read :find_web do
      argument :web_public_key, :string, allow_nil?: false

      filter expr(type == :web)
      filter expr(web_public_key == ^arg(:web_public_key))

      get? true
      prepare build(load: [:account, :sources])
    end

    read :find_discord do
      argument :discord_server_id, :integer, allow_nil?: false
      argument :discord_channel_id, :integer, allow_nil?: false

      filter expr(type == :discord)
      filter expr(discord_server_id == ^arg(:discord_server_id))
      filter expr(discord_channel_id == ^arg(:discord_channel_id))

      get? true
      prepare build(load: [:account, :sources])
    end

    create :create_web do
      argument :account, :map, allow_nil?: false
      argument :web_url, :string, allow_nil?: false

      change set_attribute(:type, :web)
      change manage_relationship(:account, :account, type: :append)
      change {Canary.Interactions.Changes.Key, attribute: :web_public_key, prefix: "pk_"}

      change fn changeset, _ ->
        url = Ash.Changeset.get_argument(changeset, :web_url)

        if is_nil(url) do
          changeset
        else
          case URI.parse(url) do
            %URI{host: nil} -> changeset
            %URI{host: host} -> Ash.Changeset.change_attribute(changeset, :web_host_url, host)
          end
        end
      end
    end

    create :create_discord do
      argument :account, :map, allow_nil?: false
      argument :discord_server_id, :integer, allow_nil?: false
      argument :discord_channel_id, :integer, allow_nil?: false

      change set_attribute(:type, :discord)
      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:discord_server_id, expr(^arg(:discord_server_id)))
      change set_attribute(:discord_channel_id, expr(^arg(:discord_channel_id)))
    end

    update :add_sources do
      require_atomic? false

      argument :sources, {:array, :map}, allow_nil?: true
      change manage_relationship(:sources, :sources, type: :append)
    end

    update :remove_sources do
      require_atomic? false

      argument :sources, {:array, :map}, allow_nil?: true
      change manage_relationship(:sources, :sources, type: :remove)
    end
  end

  code_interface do
    define :find_web,
      args: [:web_public_key],
      action: :find_web

    define :find_discord,
      args: [:discord_server_id, :discord_channel_id],
      action: :find_discord

    define :create_web,
      args: [:account, :web_url],
      action: :create_web

    define :create_discord,
      args: [:account, :discord_server_id, :discord_channel_id],
      action: :create_discord

    define :add_sources,
      args: [:sources],
      action: :add_sources

    define :remove_sources,
      args: [:sources],
      action: :remove_sources
  end

  postgres do
    table "clients"
    repo Canary.Repo
  end
end
