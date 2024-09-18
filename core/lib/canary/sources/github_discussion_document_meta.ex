defmodule Canary.Sources.GithubDiscussion.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :closed, :boolean, allow_nil?: false
    attribute :answered, :boolean, allow_nil?: false
  end
end
