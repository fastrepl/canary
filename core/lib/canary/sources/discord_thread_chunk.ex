defmodule Canary.Sources.DiscordThread.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    uuid_primary_key :id
    attribute :index_id, :uuid, allow_nil?: false
    attribute :source_id, :uuid, allow_nil?: false
    attribute :document_id, :string, allow_nil?: false

    attribute :server_id, :integer, allow_nil?: false
    attribute :channel_id, :integer, allow_nil?: false
    attribute :message_id, :integer, allow_nil?: false

    attribute :content, :string, allow_nil?: false
    attribute :created_at, :utc_datetime, allow_nil?: false
    attribute :author_name, :string, allow_nil?: false
    attribute :author_avatar_url, :string, allow_nil?: false
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :source_id,
        :server_id,
        :channel_id,
        :message_id,
        :content,
        :created_at,
        :author_name,
        :author_avatar_url
      ]

      change {Canary.Change.AddToIndex, index_id_attribute: :index_id}
    end

    destroy :destroy do
      primary? true

      change {
        Canary.Change.RemoveFromIndex,
        source_type: :discord_thread, index_id_attribute: :index_id
      }
    end
  end
end
