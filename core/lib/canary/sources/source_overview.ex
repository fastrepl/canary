defmodule Canary.Sources.SourceOverview do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :titles, {:array, :string}, default: []
    attribute :keywords, {:array, :string}, default: []
  end
end
