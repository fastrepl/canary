defmodule Canary.Sources.Webpage.Chunk do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false
    attribute :source_id, :uuid, allow_nil?: false
    attribute :document_id, :string, allow_nil?: false
    attribute :is_parent, :boolean, allow_nil?: false

    attribute :url, :string, allow_nil?: false
    attribute :title, :string, allow_nil?: false, constraints: [allow_empty?: true]
    attribute :content, :string, allow_nil?: false
    attribute :keywords, {:array, :string}, default: []
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :source_id,
        :document_id,
        :is_parent,
        :url,
        :title,
        :content,
        :keywords
      ]

      change {Canary.Change.NormalizeURL, input_argument: :url, output_attribute: :url}
      change {Canary.Change.AddToIndex, index_id_attribute: :index_id}
    end

    destroy :destroy do
      primary? true

      change {
        Canary.Change.RemoveFromIndex,
        source_type: :webpage, index_id_attribute: :index_id
      }
    end
  end
end
