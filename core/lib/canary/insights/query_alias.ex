defmodule Canary.Insights.QueryAlias do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :name, :string, allow_nil?: false
    attribute :members, {:array, :string}, default: []
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:name, :members],
      update: [:name, :members]
    ]
  end
end
