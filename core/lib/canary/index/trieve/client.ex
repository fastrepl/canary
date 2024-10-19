defmodule Canary.Index.Trieve.Client do
  defp base() do
    key = Application.fetch_env!(:canary, :trieve_api_key)
    dataset = Application.fetch_env!(:canary, :trieve_dataset)

    Canary.rest_client(
      receive_timeout: 2_000,
      base_url: "https://api.trieve.ai/api",
      headers: [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{key}"},
        {"TR-Dataset", dataset}
      ]
    )
  end

  def upsert_groups(inputs) when is_list(inputs) do
    data =
      inputs
      |> Enum.map(fn %{tracking_id: tracking_id, meta: meta} ->
        %{
          tracking_id: tracking_id,
          metadata: meta
        }
      end)

    # https://docs.trieve.ai/api-reference/chunk-group/create-or-upsert-group-or-groups
    case base() |> Req.post(url: "/chunk_group", json: data) do
      {:ok, %{status: 200, body: _}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def delete_group(group_tracking_id) do
    # https://docs.trieve.ai/api-reference/chunk-group/delete-group-by-tracking-id
    case base()
         |> Req.delete(
           url: "/chunk_group/tracking_id/#{group_tracking_id}",
           params: [delete_chunks: true]
         ) do
      {:ok, %{status: 204}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def upsert_chunks(chunks) do
    chunks
    |> Enum.chunk_every(120)
    |> Enum.reduce_while(:ok, fn batch, _acc ->
      data =
        batch
        |> Enum.map(fn chunk ->
          %{
            tracking_id: tracking_id,
            group_tracking_id: group_tracking_id,
            content: content,
            url: url,
            meta: meta,
            source_id: source_id,
            tags: tags
          } = chunk

          %{
            tracking_id: tracking_id,
            group_tracking_ids: [group_tracking_id],
            link: url,
            chunk_html: content,
            metadata: meta,
            tag_set: [
              format_for_tag(:source_id, source_id)
              | Enum.map(tags, &format_for_tag(:tag, &1))
            ],
            convert_html_to_text: false,
            upsert_by_tracking_id: true
          }
        end)

      # https://docs.trieve.ai/api-reference/chunk/create-or-upsert-chunk-or-chunks
      case base() |> Req.post(url: "/chunk", json: data) do
        {:ok, %{status: 200}} ->
          {:cont, :ok}

        {:ok, %{status: status, body: error}} when status in 400..499 ->
          {:halt, {:error, error}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  def delete_chunk(chunk_tracking_id) do
    # https://docs.trieve.ai/api-reference/chunk/delete-chunk-by-tracking-id
    case base() |> Req.post(url: "/chunk/tracking_id/#{chunk_tracking_id}") do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{status: status, body: error}} when status in 400..499 ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  def search(query, opts \\ []) do
    tags = opts[:tags]
    source_ids = Keyword.fetch!(opts, :source_ids)
    search_type = if(question?(query), do: :fulltext, else: :hybrid)

    highlight_options =
      if question?(query) do
        %{
          highlight_window: 1,
          highlight_max_length: 4,
          highlight_threshold: 0.5,
          highlight_strategy: :v1
        }
      else
        %{
          highlight_window: 1,
          highlight_max_length: 2,
          highlight_threshold: 0.9,
          highlight_strategy: :exactmatch
        }
      end

    # https://docs.trieve.ai/api-reference/chunk-group/search-over-groups
    case base()
         |> Req.post(
           url: "/chunk_group/group_oriented_search",
           json: %{
             query: query,
             filters: %{
               must:
                 [
                   %{
                     field: "tag_set",
                     match_any: Enum.map(source_ids, &format_for_tag(:source_id, &1))
                   },
                   if(not is_nil(tags) and tags != [],
                     do: %{
                       field: "tag_set",
                       match_any: Enum.map(tags, &format_for_tag(:tag, &1))
                     },
                     else: nil
                   )
                 ]
                 |> Enum.reject(&is_nil/1)
             },
             page: 1,
             page_size: 8,
             group_size: 3,
             search_type: search_type,
             score_threshold: 0.1,
             remove_stop_words: true,
             slim_chunks: false,
             typo_options: %{correct_typos: true},
             highlight_options:
               Map.merge(
                 highlight_options,
                 %{highlight_results: true, highlight_max_num: 1}
               )
           }
         ) do
      {:ok, %{status: 200, body: %{"results" => results}}} -> {:ok, results}
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  defp question?(query) do
    String.ends_with?(query, "?") or
      query =~
        ~r/^(who|whom|whose|what|which|when|where|why|how|can|is|does|do|are|could|would|may|give)\b/ or
      query
      |> String.split(" ")
      |> Enum.reject(&(&1 == ""))
      |> Enum.count() > 2
  end

  defp format_for_tag(:source_id, value), do: "source_id:#{value}"
  defp format_for_tag(:tag, value), do: "tag:#{value}"
end
