defmodule Canary.Sources.GithubIssue.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :node_id, :string, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: [:node_id], update: [:node_id]]
  end
end
