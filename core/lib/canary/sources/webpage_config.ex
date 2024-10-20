defmodule Canary.Sources.Webpage.Config do
  use Ash.Resource, data_layer: :embedded

  alias Canary.Sources.Webpage.TagDefinition

  attributes do
    attribute :start_urls, {:array, :string}, default: []
    attribute :url_include_patterns, {:array, :string}, default: []
    attribute :url_exclude_patterns, {:array, :string}, default: []
    attribute :tag_definitions, {:array, TagDefinition}, default: []
    attribute :js_render, :boolean, default: false
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :start_urls,
        :url_include_patterns,
        :url_exclude_patterns,
        :tag_definitions,
        :js_render
      ]
    end

    update :update do
      primary? true

      accept [
        :start_urls,
        :url_include_patterns,
        :url_exclude_patterns,
        :tag_definitions,
        :js_render
      ]
    end
  end
end
