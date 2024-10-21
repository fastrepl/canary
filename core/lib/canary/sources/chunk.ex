defmodule Canary.Sources.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: [:index_id]]
  end
end
