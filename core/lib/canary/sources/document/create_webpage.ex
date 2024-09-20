defmodule Canary.Sources.Document.CreateWebpage do
  use Ash.Resource.Change

  alias Canary.Sources.Document
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
  def change(changeset, opts, _context) do
    source_id = Ash.Changeset.get_argument(changeset, opts[:source_id_argument])
    fetcher_result = Ash.Changeset.get_argument(changeset, opts[:fetcher_result_argument])

    changeset
    |> Ash.Changeset.change_attribute(opts[:meta_attribute], wrap_union(%Webpage.DocumentMeta{}))
    |> Ash.Changeset.change_attribute(opts[:chunks_attribute], [])
    |> Ash.Changeset.after_action(fn _, record ->
      %Webpage.FetcherResult{url: url, html: html, items: items} = fetcher_result
      top_level_item = items |> Enum.at(0)

      hash =
        html
        |> then(&:crypto.hash(:sha256, &1))
        |> Base.encode16(case: :lower)

      chunks_create_result =
        items
        |> Enum.map(fn %Canary.Scraper.Item{} = item ->
          %{
            source_id: source_id,
            document_id: record.id,
            title: item.title,
            content: item.content,
            url: URI.parse(url) |> Map.put(:fragment, item.id) |> to_string()
          }
        end)
        |> Ash.bulk_create(Webpage.Chunk, :create,
          return_errors?: true,
          return_records?: true
        )

      meta = %{
        title: top_level_item.title,
        url: url,
        hash: hash
      }

      case chunks_create_result do
        %Ash.BulkResult{status: :success, records: records} ->
          case Document.update(record, wrap_union(meta), Enum.map(records, &wrap_union/1)) do
            {:ok, updated_record} -> {:ok, updated_record}
            error -> error
          end

        %Ash.BulkResult{errors: errors} ->
          {:error, errors}
      end
    end)
  end

  defp wrap_union(%Ash.Union{} = v), do: v
  defp wrap_union(v), do: %Ash.Union{type: :webpage, value: v}
end
