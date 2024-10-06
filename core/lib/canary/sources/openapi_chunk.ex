defmodule Canary.Sources.OpenAPI.Chunk do
  use Ash.Resource, data_layer: :embedded

  @ops [:get, :post, :put, :delete]

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
    attribute :source_id, :uuid, allow_nil?: false
    attribute :document_id, :string, allow_nil?: false

    attribute :url, :string, allow_nil?: false
    attribute :path, :string, allow_nil?: false

    Enum.each(@ops, fn op ->
      attribute op, :string, allow_nil?: true
    end)
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:index_id, :source_id, :document_id] ++ [:url, :path] ++ @ops
      change {Canary.Change.AddToIndex, index_id_attribute: :index_id}
    end

    destroy :destroy do
      primary? true

      change {
        Canary.Change.RemoveFromIndex,
        source_type: :openapi, index_id_attribute: :index_id
      }
    end
  end
end
