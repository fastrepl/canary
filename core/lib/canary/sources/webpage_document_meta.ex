defmodule Canary.Sources.Webpage.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :url, :string, allow_nil?: false
    attribute :hash, :string, allow_nil?: false
    attribute :tags, {:array, :string}, default: []
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [:url, :hash, :tags]
      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
    end

    update :update do
      primary? true

      accept [:url, :hash, :tags]
      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
    end
  end
end
