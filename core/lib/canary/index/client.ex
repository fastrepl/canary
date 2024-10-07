defmodule Canary.Index.Client do
  defp base() do
    typesense = Application.fetch_env!(:canary, :typesense)

    Canary.rest_client(
      base_url: typesense[:base_url],
      headers: [{"x-typesense-api-key", typesense[:api_key]}]
    )
  end

  defp wrap({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp wrap({:ok, %Req.Response{body: body}}), do: {:error, body}
  defp wrap({:error, %Req.Response{body: body}}), do: {:error, body}

  def get_collection(name) do
    base()
    |> Req.get(url: "/collections/#{name}")
    |> wrap()
  end

  def create_collection(name, fields) do
    base()
    |> Req.post(
      url: "/collections",
      json: %{
        name: name,
        fields: fields,
        enable_nested_fields: true,
        token_separators: [".", "-", "_"]
      }
    )
    |> wrap()
  end

  def upsert_stopwords_set(id, data) do
    base()
    |> Req.put(
      url: "/stopwords/#{id}",
      json: data
    )
    |> wrap()
  end

  def index_document(collection, doc) do
    base()
    |> Req.post(
      url: "/collections/#{collection}/documents",
      json: doc
    )
    |> wrap()
  end

  def batch_index_document(collection, docs) when is_list(docs) do
    jsonl_docs = docs |> Enum.map(&Jason.encode!/1) |> Enum.join("\n")

    base()
    |> Req.post(
      url: "/collections/#{collection}/documents/import",
      body: jsonl_docs,
      headers: [{"Content-Type", "text/plain"}]
    )
    |> wrap()
  end

  def delete_document(collection, id) do
    base()
    |> Req.delete(
      url: "/collections/#{collection}/documents/#{id}",
      params: [ignore_not_found: true]
    )
    |> wrap()
  end

  def batch_delete_document(collection, ids) when is_list(ids) do
    filter = "id:=[#{Enum.join(ids, ",")}]"

    base()
    |> Req.delete(
      url: "/collections/#{collection}/documents",
      params: [filter_by: filter]
    )
    |> wrap()
  end

  def multi_search(data) when is_list(data) and length(data) > 0 do
    base()
    |> Req.post(
      url: "/multi_search",
      json: %{searches: data}
    )
    |> wrap()
  end
end
