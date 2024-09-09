defmodule Canary.Sources.DiscordThread.Config do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :server_id, :integer, allow_nil?: false
    attribute :channel_ids, {:array, :integer}, default: []
  end

  actions do
    defaults [:read, create: [:server_id, :channel_ids], update: [:server_id, :channel_ids]]
  end
end
