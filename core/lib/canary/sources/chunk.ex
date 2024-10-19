defmodule Canary.Sources.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
  end

  actions do
    defaults [:read, create: [:index_id]]

    destroy :destroy do
      primary? true
      change {Canary.Index.Trieve.Changes.DeleteChunk, tracking_id_attribute: :index_id}
    end
  end
end
