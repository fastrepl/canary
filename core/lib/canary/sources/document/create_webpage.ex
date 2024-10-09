defmodule Canary.Sources.Document.CreateWebpage do
  use Ash.Resource.Change

  alias Canary.Sources.Webpage

  @impl true
  def init(opts) do
    if [
         :source_id_argument,
         :fetcher_result_argument,
         :meta_attribute,
         :chunks_attribute
       ]
       |> Enum.any?(&is_nil(opts[&1])) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def before_batch(changesets, opts, _context) do
    changesets =
      changesets
      |> Enum.map(fn changeset ->
        changeset
        |> Ash.Changeset.force_change_attribute(:id, Ash.UUID.generate())
      end)

    chunk_inputs =
      changesets
      |> Enum.flat_map(fn changeset ->
        document_id = Ash.Changeset.get_attribute(changeset, :id)
        source_id = Ash.Changeset.get_argument(changeset, opts[:source_id_argument])
        fetcher_result = Ash.Changeset.get_argument(changeset, opts[:fetcher_result_argument])

        %Webpage.FetcherResult{url: url, items: items, tags: tags} = fetcher_result

        items
        |> Enum.with_index(0)
        |> Enum.map(fn {%Canary.Scraper.Item{} = item, index} ->
          %{
            source_id: source_id,
            document_id: document_id,
            is_parent: index == 0,
            title: item.title,
            content: item.content,
            tags: tags,
            url: URI.parse(url) |> Map.put(:fragment, item.id) |> to_string()
          }
        end)
      end)

    bulk_opts = [return_errors?: true, return_records?: true, batch_size: 100]

    case Ash.bulk_create(chunk_inputs, Webpage.Chunk, :create, bulk_opts) do
      %Ash.BulkResult{status: :success, records: records} ->
        doc_id_to_chunks =
          records
          |> Enum.group_by(& &1.document_id)

        changesets
        |> Enum.map(fn changeset ->
          document_id = Ash.Changeset.get_attribute(changeset, :id)
          chunks = doc_id_to_chunks[document_id] || []

          changeset
          |> Ash.Changeset.change_attribute(opts[:chunks_attribute], wrap_union(chunks))
        end)

      %Ash.BulkResult{errors: errors} ->
        changesets
        |> Enum.map(fn changeset ->
          changeset
          |> Ash.Changeset.add_error(errors)
          |> Ash.Changeset.change_attribute(opts[:chunks_attribute], [])
        end)
    end
  end

  @impl true
  def batch_change(changesets, opts, _context) do
    changesets
    |> Enum.map(fn changeset ->
      fetcher_result = Ash.Changeset.get_argument(changeset, opts[:fetcher_result_argument])
      %Webpage.FetcherResult{url: url, html: html, items: items, tags: tags} = fetcher_result
      top_level_item = items |> Enum.at(0)

      hash =
        html
        |> then(&:crypto.hash(:sha256, &1))
        |> Base.encode16(case: :lower)

      meta =
        Webpage.DocumentMeta
        |> Ash.Changeset.for_create(:create, %{
          title: top_level_item.title,
          url: url,
          hash: hash,
          tags: tags
        })
        |> Ash.create!()
        |> then(&wrap_union/1)

      changeset
      |> Ash.Changeset.change_attribute(opts[:meta_attribute], meta)
    end)
  end

  defp wrap_union(v) when is_list(v), do: Enum.map(v, &wrap_union/1)
  defp wrap_union(%Ash.Union{} = v), do: v
  defp wrap_union(v), do: %Ash.Union{type: :webpage, value: v}
end
