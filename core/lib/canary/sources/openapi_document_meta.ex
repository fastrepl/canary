defmodule Canary.Sources.OpenAPI.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
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
