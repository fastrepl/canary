defmodule Canary.Sources.GithubDiscussion.DocumentMeta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :title, :string, allow_nil?: false
    attribute :url, :string, allow_nil?: false
    attribute :closed, :boolean, allow_nil?: true
    attribute :answered, :boolean, allow_nil?: true
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [:title, :url, :closed, :answered]
      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
    end

    update :update do
      primary? true

      accept [:title, :url, :closed, :answered]
      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
    end
  end
end
