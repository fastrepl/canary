defmodule Canary.Sources.Chunk do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: :embedded

  attributes do
    attribute :index_id, :uuid, allow_nil?: false

    attribute :source_id, :uuid, allow_nil?: false
    attribute :url, :string, allow_nil?: false, constraints: [allow_empty?: true]
    attribute :title, :string, allow_nil?: false
    attribute :content, :string, allow_nil?: false
    attribute :titles, {:array, :string}, allow_nil?: false
    attribute :tags, {:array, :string}, allow_nil?: false
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :source_id, :uuid, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :title, :string, allow_nil?: false
      argument :content, :string, allow_nil?: false
      argument :titles, {:array, :string}, allow_nil?: false
      argument :tags, {:array, :string}, allow_nil?: false

      change set_attribute(:source_id, arg(:source_id))
      change set_attribute(:url, arg(:url))
      change set_attribute(:title, arg(:title))
      change set_attribute(:content, arg(:content))
      change set_attribute(:titles, arg(:titles))
      change set_attribute(:tags, arg(:tags))

      change Canary.Sources.Chunk.Changes.InsertToIndex
    end

    destroy :destroy do
      primary? true

      change Canary.Sources.Chunk.Changes.RemoveFromIndex
    end
  end
end

defmodule Canary.Sources.Chunk.Changes.InsertToIndex do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    index_id = Ash.UUID.generate()

    doc = %Canary.Index.Document{
      id: index_id,
      title: Ash.Changeset.get_argument(changeset, :title),
      content: Ash.Changeset.get_argument(changeset, :content),
      source: Ash.Changeset.get_argument(changeset, :source_id),
      tags: Ash.Changeset.get_argument(changeset, :tags),
      meta: %{
        url: Ash.Changeset.get_argument(changeset, :url),
        titles: Ash.Changeset.get_argument(changeset, :titles)
      }
    }

    changeset
    |> Ash.Changeset.force_change_attribute(:index_id, index_id)
    |> Ash.Changeset.after_action(fn _changeset, record ->
      case Canary.Index.insert_document(doc) do
        {:ok, _} -> {:ok, record}
        error -> error
      end
    end)
  end
end

defmodule Canary.Sources.Chunk.Changes.RemoveFromIndex do
  use Ash.Resource.Change

  @impl true
  def atomic(changeset, opts, context) do
    changeset = change(changeset, opts, context)
    {:ok, changeset}
  end

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _changeset, record ->
      id = Map.get(record, :index_id)

      case Canary.Index.delete_document(id) do
        {:ok, _} -> {:ok, record}
        error -> error
      end
    end)
  end
end
