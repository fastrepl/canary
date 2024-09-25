defmodule Canary.Index.Client do
  defp base() do
    typesense = Application.fetch_env!(:canary, :typesense)

    Req.new(
      base_url: typesense[:base_url],
      headers: [{"x-typesense-api-key", typesense[:api_key]}]
    )
  end

  defp wrap({:error, %Req.Response{} = resp}), do: {:error, resp}
  defp wrap({:ok, %Req.Response{status: status} = resp}) when status in 200..299, do: {:ok, resp}
  defp wrap({:ok, %Req.Response{} = resp}), do: {:error, resp}

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

  def delete_document(collection, id) do
    base()
    |> Req.delete(url: "/collections/#{collection}/documents/#{id}")
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
