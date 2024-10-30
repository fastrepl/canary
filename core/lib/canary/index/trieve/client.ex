defmodule Canary.Index.Trieve do
  @callback client(any()) :: any()
  @callback create_dataset(any(), any()) :: any()
  @callback delete_dataset(any(), any()) :: any()
  @callback upsert_groups(any(), any()) :: any()
  @callback delete_group(any(), any()) :: any()
  @callback upsert_chunks(any(), any()) :: any()
  @callback delete_chunk(any(), any()) :: any()
  @callback search(any(), any(), keyword()) :: any()
  @callback get_chunks(any(), any(), keyword()) :: any()

  def client(_ \\ nil)
  def client(%Canary.Accounts.Project{index_id: id}), do: client(id)
  def client(dataset), do: impl().client(dataset)

  def create_dataset(client, tracking_id), do: impl().create_dataset(client, tracking_id)
  def delete_dataset(client, tracking_id), do: impl().delete_dataset(client, tracking_id)
  def upsert_groups(client, inputs), do: impl().upsert_groups(client, inputs)
  def delete_group(client, group_tracking_id), do: impl().delete_group(client, group_tracking_id)
  def upsert_chunks(client, chunks), do: impl().upsert_chunks(client, chunks)
  def delete_chunk(client, chunk_tracking_id), do: impl().delete_chunk(client, chunk_tracking_id)
  def search(client, query, opts \\ []), do: impl().search(client, query, opts)

  def get_chunks(client, group_tracking_id, opts \\ []),
    do: impl().get_chunks(client, group_tracking_id, opts)

  defp impl(), do: Application.get_env(:canary, :trieve, Canary.Index.Trieve.Actual)
end

defmodule Canary.Index.Trieve.Actual do
  @behaviour Canary.Index.Trieve

  def client(dataset) do
    key = Application.fetch_env!(:canary, :trieve_api_key)
    org = Application.fetch_env!(:canary, :trieve_organization)

    Canary.rest_client(
      base_url: "https://api.trieve.ai/api",
      headers:
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{key}"},
          {"TR-Organization", org},
          if(not is_nil(dataset), do: {"TR-Dataset", dataset}, else: nil)
        ]
        |> Enum.reject(&is_nil/1),
      receive_timeout: 4_000
    )
  end

  def create_dataset(client, tracking_id) do
    # https://docs.trieve.ai/api-reference/dataset/create-dataset
    case client
         |> Req.post(
           url: "/dataset",
           json: %{
             dataset_name: tracking_id,
             tracking_id: tracking_id,
             server_configuration: %{
               LOCKED: Application.get_env(:canary, :env) == :prod
             }
           }
         ) do
      {:ok, %{status: 200, body: _}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def delete_dataset(client, tracking_id) do
    # https://docs.trieve.ai/api-reference/dataset/delete-dataset-by-tracking-id
    case client
         |> Req.delete(
           url: "/dataset/tracking_id/#{tracking_id}",
           headers: [{"TR-Dataset", tracking_id}]
         ) do
      {:ok, %{status: 204}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def upsert_groups(client, inputs) when is_list(inputs) do
    data =
      inputs
      |> Enum.map(fn %{tracking_id: tracking_id, meta: meta} ->
        %{
          metadata: meta,
          tracking_id: tracking_id,
          upsert_by_tracking_id: true
        }
      end)

    # https://docs.trieve.ai/api-reference/chunk-group/create-or-upsert-group-or-groups
    case client |> Req.post(url: "/chunk_group", json: data) do
      {:ok, %{status: 200, body: _}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def delete_group(client, group_tracking_id) do
    # https://docs.trieve.ai/api-reference/chunk-group/delete-group-by-tracking-id
    case client
         |> Req.delete(
           url: "/chunk_group/tracking_id/#{group_tracking_id}",
           params: [delete_chunks: true]
         ) do
      {:ok, %{status: 204}} -> :ok
      {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end

  def upsert_chunks(client, chunks) do
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

          tag_set =
            if is_nil(tags) or tags == [] do
              [
                format_for_tagset(:source_id, source_id),
                format_for_tagset(:empty_tags)
              ]
            else
              [
                format_for_tagset(:source_id, source_id)
                | Enum.map(tags, &format_for_tagset(:tag, &1))
              ]
            end

          %{
            tracking_id: tracking_id,
            group_tracking_ids: [group_tracking_id],
            link: url,
            chunk_html: content,
            metadata: meta,
            tag_set: tag_set,
            convert_html_to_text: false,
            upsert_by_tracking_id: true
          }
          |> then(fn data ->
            if is_struct(chunk[:created_at], DateTime) do
              data
              |> Map.put(:time_stamp, DateTime.to_iso8601(chunk.created_at))
            else
              data
            end
          end)
          |> then(fn data ->
            if is_binary(chunk[:title]) do
              data
              |> Map.merge(%{
                fulltext_boost: %{boost_factor: 3, phrase: chunk.title},
                semantic_boost: %{boost_factor: 0.3, phrase: chunk.title}
              })
            else
              data
            end
          end)
          |> then(fn data ->
            if chunk[:weight] do
              data |> Map.put(:weight, chunk[:weight])
            else
              data
            end
          end)
        end)

      # https://docs.trieve.ai/api-reference/chunk/create-or-upsert-chunk-or-chunks
      case client |> Req.post(url: "/chunk", json: data) do
        {:ok, %{status: 200}} ->
          {:cont, :ok}

        {:ok, %{status: status, body: error}} when status in 400..499 ->
          {:halt, {:error, error}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  def delete_chunk(client, chunk_tracking_id) do
    # https://docs.trieve.ai/api-reference/chunk/delete-chunk-by-tracking-id
    case client |> Req.post(url: "/chunk/tracking_id/#{chunk_tracking_id}") do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{status: status, body: error}} when status in 400..499 ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  def search(client, query, opts \\ []) do
    rag? = Keyword.get(opts, :rag, false)
    tags = Keyword.get(opts, :tags, nil)
    source_ids = Keyword.get(opts, :source_ids, nil)

    search_type = :fulltext
    remove_stop_words = not (rag? or question?(query))
    group_size = if(rag?, do: 5, else: 3)
    page_size = if(rag?, do: 12, else: 8)
    score_threshold = 0.3

    highlight_options =
      cond do
        rag? ->
          %{highlight_results: false}

        question?(query) ->
          %{
            highlight_window: 12,
            highlight_max_length: 6,
            highlight_threshold: 0.4,
            highlight_strategy: :v1
          }

        true ->
          %{
            highlight_window: 12,
            highlight_max_length: 2,
            highlight_strategy: :exactmatch
          }
      end

    filters =
      if is_nil(source_ids) do
        [%{must: [filter_for_tags(tags)] |> Enum.reject(&is_nil/1)}]
      else
        source_ids
        |> Enum.map(fn id ->
          %{must: [filter_for_tags(tags), filter_for_source_id(id)] |> Enum.reject(&is_nil/1)}
        end)
      end

    result =
      filters
      |> Enum.map(fn f ->
        Task.async(fn ->
          client
          |> run_search(%{
            filters: f,
            query: query,
            page: 1,
            page_size: page_size,
            group_size: group_size,
            search_type: search_type,
            score_threshold: score_threshold,
            remove_stop_words: remove_stop_words,
            typo_options: %{
              correct_typos: true,
              one_typo_word_range: %{min: 3, max: 3 * 3},
              two_typo_word_range: %{min: 4, max: 4 * 3}
            },
            highlight_options:
              Map.merge(
                %{
                  highlight_results: true,
                  highlight_max_num: 1,
                  pre_tag: "<mark>",
                  post_tag: "</mark>"
                },
                highlight_options
              )
          })
        end)
      end)
      |> Task.await_many(5_000)

    if Enum.all?(result, &match?({:error, _}, &1)) do
      {:error, result}
    else
      merged =
        result
        |> Enum.flat_map(fn
          {:ok, v} -> v
          _ -> []
        end)
        |> Enum.sort_by(
          fn %{"chunks" => chunks} ->
            chunks
            |> Enum.max_by(& &1["score"])
            |> Map.get("score")
          end,
          :desc
        )

      {:ok, merged}
    end
  end

  defp filter_for_source_id(id) do
    %{
      field: "tag_set",
      match_any: [format_for_tagset(:source_id, id)]
    }
  end

  defp filter_for_tags(nil), do: nil
  defp filter_for_tags([]), do: nil

  defp filter_for_tags(tags) do
    %{
      field: "tag_set",
      match_any: [
        format_for_tagset(:empty_tags)
        | Enum.map(tags, &format_for_tagset(:tag, &1))
      ]
    }
  end

  defp run_search(client, data) do
    # https://docs.trieve.ai/api-reference/chunk-group/search-over-groups
    case client
         |> Req.post(
           url: "/chunk_group/group_oriented_search",
           json: data
         ) do
      {:ok, %{status: 200, body: %{"results" => results}}} ->
        {:ok, results}

      {:ok, %{status: status, body: error}} when status in 400..499 ->
        if error["message"] =~ "Should have at least one value for match" do
          {:ok, []}
        else
          {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def get_chunks(client, group_tracking_id, opts \\ []) do
    page_size = 10
    chunk_indices = Keyword.get(opts, :chunk_indices, [0])

    pages =
      chunk_indices
      |> Enum.map(&(div(&1, page_size) + 1))
      |> Enum.uniq()
      |> Enum.sort()

    result =
      pages
      |> Enum.map(fn page ->
        Task.async(fn ->
          # https://docs.trieve.ai/api-reference/chunk-group/get-chunks-in-group-by-tracking-id
          case client |> Req.get(url: "/chunk_group/tracking_id/#{group_tracking_id}/#{page}") do
            {:ok, %{status: 200, body: result}} -> {:ok, result}
            {:ok, %{status: status, body: error}} when status in 400..499 -> {:error, error}
            {:error, error} -> {:error, error}
          end
        end)
      end)
      |> Task.await_many(5_000)

    if Enum.all?(result, &match?({:error, _}, &1)) do
      {:error, result}
    else
      chunks =
        result
        |> Enum.flat_map(fn
          {:ok, %{"chunks" => chunks}} -> chunks
          _ -> []
        end)

      {:ok, %{"chunks" => chunks}}
    end
  end

  defp question?(query) do
    String.ends_with?(query, "?") or
      query =~
        ~r/^(who|whom|whose|what|which|when|where|why|how|can|is|does|do|are|could|would|may|give)\b/ or
      query
      |> String.split(" ")
      |> Enum.reject(&(&1 == ""))
      |> Enum.count() > 3
  end

  defp format_for_tagset(:empty_tags), do: "__empty_tags__"
  defp format_for_tagset(:source_id, value), do: "__source_id:#{value}__"
  defp format_for_tagset(:tag, value), do: "__tag:#{value}__"
end
