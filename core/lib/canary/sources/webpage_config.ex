defmodule Canary.Sources.Webpage.Config do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :start_urls, {:array, :string}, default: []
    attribute :url_include_patterns, {:array, :string}, default: []
    attribute :url_exclude_patterns, {:array, :string}, default: []
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:start_urls, :url_include_patterns, :url_exclude_patterns]
    end

    update :update do
      primary? true
      accept [:start_urls, :url_include_patterns, :url_exclude_patterns]
    end
  end
end
