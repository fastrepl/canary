defmodule Canary.Sources.Document.CreateWebpage do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if [
         :source_id_argument,
         :url_argument,
         :html_argument,
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
    url = Ash.Changeset.get_argument(changeset, opts[:url_argument])
    html = Ash.Changeset.get_argument(changeset, opts[:html_argument])

    items = Canary.Scraper.run!(html)

    hash =
      html
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    meta = %Ash.Union{
      type: :webpage,
      value: %Canary.Sources.Webpage.DocumentMeta{url: url, hash: hash}
    }

    %{errors: _, records: chunks} =
      items
      |> Enum.map(fn %Canary.Scraper.Item{} = item ->
        %{
          source_id: source_id,
          title: item.title,
          content: item.content,
          url: URI.parse(url) |> Map.put(:fragment, item.id) |> URI.to_string()
        }
      end)
      |> Ash.bulk_create(Canary.Sources.Webpage.Chunk, :create,
        return_errors?: true,
        return_records?: true
      )

    changeset
    |> Ash.Changeset.change_attribute(opts[:meta_attribute], meta)
    |> Ash.Changeset.change_attribute(opts[:chunks_attribute], chunks)
  end
end
