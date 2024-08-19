defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    update_timestamp :updated_at

    attribute :url, :string, allow_nil?: true
    attribute :content, :binary, allow_nil?: false
    attribute :chunks, {:array, Canary.Sources.Chunk}, default: []

    attribute :summary, :string, allow_nil?: true
  end

  identities do
    identity :unique_document, [:source_id, :url]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read]

    read :find_by_chunk_index_id do
      argument :id, :string, allow_nil?: false
      get? true

      filter expr(
               fragment(
                 "EXISTS (SELECT 1 FROM unnest(?) AS chunk WHERE (chunk->>'index_id')::text = ?)",
                 chunks,
                 ^arg(:id)
               )
             )
    end

    create :create do
      argument :source_id, :uuid, allow_nil?: false

      argument :url, :string, allow_nil?: false
      argument :title, :string, allow_nil?: false
      argument :html, :string, allow_nil?: false
      argument :tags, {:array, :string}, default: []

      change set_attribute(:url, arg(:url))
      change manage_relationship(:source_id, :source, type: :append)
      change Canary.Sources.Document.Changes.CreateChunks
      change Canary.Sources.Document.Changes.CreateSummary
    end

    destroy :destroy do
      change Canary.Sources.Document.Changes.DestroyChunks
    end

    update :update_summary do
      argument :summary, :string, allow_nil?: false
      change set_attribute(:summary, expr(^arg(:summary)))
    end
  end

  code_interface do
    define :update_summary, args: [:summary], action: :update_summary
    define :find_by_chunk_index_id, args: [:id], action: :find_by_chunk_index_id
  end

  postgres do
    table "documents"
    repo Canary.Repo
  end
end

defmodule Canary.Sources.Document.Changes.CreateChunks do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    source_id = Ash.Changeset.get_argument(changeset, :source_id)
    url = Ash.Changeset.get_argument(changeset, :url)
    html = changeset |> Ash.Changeset.get_argument(:html)
    content = Canary.Reader.markdown_from_html(html)
    sections = Canary.Reader.markdown_sections_from_html(html)

    title = Ash.Changeset.get_argument(changeset, :title)
    tags = Ash.Changeset.get_argument(changeset, :tags)

    inputs =
      sections
      |> Enum.map(fn section ->
        titles =
          if(is_nil(section[:title])) do
            %{title: title, titles: []}
          else
            %{title: section[:title], titles: [title]}
          end

        %{
          source_id: source_id,
          url: URI.parse(url) |> Map.put(:fragment, section[:id]) |> URI.to_string(),
          content: section.content,
          tags: tags
        }
        |> Map.merge(titles)
      end)

    opts = [return_errors?: true, return_records?: true]

    chunks =
      case Ash.bulk_create(inputs, Canary.Sources.Chunk, :create, opts) do
        %{status: :success, records: chunks} ->
          chunks

        error ->
          IO.inspect(error)
          []
      end

    changeset
    |> Ash.Changeset.force_change_attribute(:content, content)
    |> Ash.Changeset.force_change_attribute(:chunks, chunks)
  end
end

defmodule Canary.Sources.Document.Changes.DestroyChunks do
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
      case Ash.bulk_destroy(record.chunks, :destroy, %{}, return_errors?: true) do
        %{status: :success} -> {:ok, record}
        %{errors: errors} -> {:error, errors}
      end
    end)
  end
end

defmodule Canary.Sources.Document.Changes.CreateSummary do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _changeset, record ->
      %{"document_id" => record.id}
      |> Canary.Workers.Summary.new()
      |> Oban.insert()

      {:ok, record}
    end)
  end
end
