defmodule Canary.Sources.Webpage.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :url, :string, allow_nil?: false
    attribute :hash, :string, allow_nil?: false
  end
end
