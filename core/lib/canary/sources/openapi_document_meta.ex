defmodule Canary.Sources.OpenAPI.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :hash, :string, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:hash]
    end

    update :update do
      primary? true
      accept [:hash]
    end
  end
end
