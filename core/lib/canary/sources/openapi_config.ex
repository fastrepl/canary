defmodule Canary.Sources.OpenAPI.Config do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :source_url, :string, allow_nil?: false
    attribute :served_url, :string, allow_nil?: false

    attribute :served_as, :atom,
      constraints: [one_of: [:swagger, :redoc, :rapi]],
      allow_nil?: true
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:source_url, :served_url, :served_as]
    end

    update :update do
      primary? true
      accept [:source_url, :served_url, :served_as]
    end
  end
end
