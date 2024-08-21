defmodule Canary.Sources.DocumentSummary do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: :embedded

  attributes do
    attribute :keywords, {:array, :string}, allow_nil?: false, default: []
  end
end
