defmodule Canary.Sources.OpenAPI.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
    attribute :source_id, :uuid, allow_nil?: false
    attribute :document_id, :string, allow_nil?: false
    attribute :is_parent, :boolean, allow_nil?: false

    attribute :tags, {:array, :string}, default: []
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
    end

    update :update do
      primary? true
    end
  end
end
