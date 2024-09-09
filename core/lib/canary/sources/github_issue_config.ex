defmodule Canary.Sources.GithubIssue.Config do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :owner, :string, allow_nil?: false
    attribute :repo, :string, allow_nil?: false
  end

  actions do
    defaults [:read, create: [:owner, :repo], update: [:owner, :repo]]
  end
end
