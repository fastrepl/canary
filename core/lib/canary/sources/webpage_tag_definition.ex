defmodule Canary.Sources.Webpage.TagDefinition do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :name, :string, allow_nil?: false
    attribute :url_include_patterns, {:array, :string}, default: []
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:name, :url_include_patterns]
    end

    update :update do
      primary? true
      accept [:name, :url_include_patterns]
    end
  end
end
