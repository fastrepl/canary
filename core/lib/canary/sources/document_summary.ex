defmodule Canary.Sources.DocumentSummary do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: :embedded

  attributes do
    attribute :keywords, {:array, :struct}, allow_nil?: false, default: []
  end
end
