defmodule Canary.Sources.GithubIssue.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
    attribute :source_id, :uuid, allow_nil?: false
    attribute :document_id, :string, allow_nil?: false
    attribute :node_id, :string, allow_nil?: false

    attribute :url, :string
    attribute :title, :string, constraints: [allow_empty?: true]
    attribute :content, :string
    attribute :created_at, :utc_datetime
    attribute :author_name, :string
    attribute :author_avatar_url, :string
    attribute :comment, :boolean
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :source_id,
        :document_id,
        :node_id,
        :url,
        :title,
        :content,
        :created_at,
        :author_name,
        :author_avatar_url,
        :comment
      ]

      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
      change {Canary.Change.AddToIndex, index_id_attribute: :index_id}
    end

    destroy :destroy do
      primary? true

      change {
        Canary.Change.RemoveFromIndex,
        source_type: :github_issue, index_id_attribute: :index_id
      }
    end
  end
end
