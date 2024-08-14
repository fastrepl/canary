if Application.get_env(:canary, :env) != :prod do
  defmodule Canary.Eval do
    import Ecto.Query

    @root Application.compile_env!(:canary, :root)

    defp spec_file_path(name), do: @root |> Path.join("../eval/datasets/#{name}.spec.yaml")
    defp data_dir_path(name), do: @root |> Path.join("../eval/datasets/#{name}")

    defp create_source(name) do
      account = Canary.Mock.account()
      source = Canary.Sources.Source.create!(account, "https://example.com")

      case @root
           |> Path.join("../eval/datasets/#{name}/*.json")
           |> Path.expand()
           |> Path.wildcard()
           |> Enum.map(&File.read!/1)
           |> Enum.map(&Jason.decode!/1)
           |> Enum.map(fn %{"url" => url, "content" => html} ->
             title = Canary.Reader.title_from_html(html)
             content = Canary.Reader.markdown_from_html(html)
             %{source: source.id, url: url, title: title, content: content}
           end)
           |> Ash.bulk_create(Canary.Sources.Document, :create, return_errors?: true) do
        %Ash.BulkResult{status: :error, errors: errors} -> IO.inspect(errors)
        _ -> :ok
      end

      ProgressBar.render_spinner([text: "Ingesting...", done: "Done!"], fn ->
        wait_for_oban()
      end)

      source
    end

    def eval_dataset(name, source_id \\ nil) do
      source =
        if source_id, do: Ash.get!(Canary.Sources.Source, source_id), else: create_source(name)

      IO.puts("\nUsing '#{source.id}' as source\n")

      spec =
        name
        |> spec_file_path()
        |> YamlElixir.read_from_file!()

      metcics = spec |> Map.get("metrics")

      dataset =
        spec
        |> Map.get("dataset")
        |> Enum.map(fn item ->
          {:ok, contexts} = Canary.Searcher.run(source, item["question"])
          contexts = contexts |> Enum.map(& &1.content)

          %{question: item["question"], contexts: contexts, ground_truth: item["ground_truth"]}
          |> Enum.reject(fn {_, v} -> is_nil(v) end)
          |> Map.new()
        end)

      eval_request(%{metrics: metcics, dataset: dataset})
    end

    defp eval_request(data) do
      %{api_base: api_base, api_key: api_key} = fetch_env()

      Req.post!(
        base_url: api_base,
        url: "/eval/new",
        json: data,
        receive_timeout: 60_000,
        auth: {:bearer, api_key}
      )
      |> get_in([Access.key(:body), "id"])
      |> then(fn id -> "#{api_base}/eval/result/#{id}" end)
    end

    def init_dataset(name, url, opts \\ []) do
      data_dir_path(name) |> File.mkdir_p!()

      {:ok, map} =
        ProgressBar.render_spinner([text: "Crawling...", done: "Done!"], fn ->
          Canary.Crawler.run(url, opts)
        end)

      map
      |> Enum.each(fn {url, html} ->
        filename = :crypto.hash(:md5, url) |> Base.encode16() |> Kernel.<>(".json")
        content = %{url: url, content: html} |> Jason.encode!()

        data_dir_path(name)
        |> Path.join(filename)
        |> File.write!(content)

        File.write!(
          spec_file_path(name),
          encode_yaml(%{
            "metrics" => [],
            "outputs" => [],
            "dataset" => []
          })
        )
      end)

      IO.puts("\n")
    end

    def synthesize_dataset(name) do
      docs =
        @root
        |> Path.join("../eval/datasets/#{name}/*.json")
        |> Path.expand()
        |> Path.wildcard()
        |> Enum.map(&File.read!/1)
        |> Enum.map(&Jason.decode!/1)
        |> Enum.map(fn %{"content" => html} ->
          Canary.Reader.markdown_from_html(html)
        end)

      synthesize_request(%{documents: docs})
    end

    def synthesize_dataset_postprocess(name, url) do
      items =
        Req.get!(url: url)
        |> Map.get(:body)
        |> Enum.map(fn %{"input" => question, "expected_output" => ground_truth} ->
          %{question: question, ground_truth: ground_truth}
        end)

      name
      |> spec_file_path()
      |> YamlElixir.read_from_file!()
      |> Map.update!("dataset", fn dataset -> dataset ++ items end)
      |> encode_yaml()
      |> then(fn spec -> File.write!(spec_file_path(name), spec) end)
    end

    defp synthesize_request(data) do
      %{api_base: api_base, api_key: api_key} = fetch_env()

      Req.post!(
        base_url: api_base,
        url: "/synthesize/new",
        json: data,
        receive_timeout: 60_000,
        auth: {:bearer, api_key}
      )
      |> get_in([Access.key(:body), "id"])
      |> then(fn id -> "#{api_base}/synthesize/result/#{id}" end)
    end

    defp wait_for_oban() do
      query =
        from job in Oban.Job,
          where: job.state not in ["completed", "discarded", "cancelled"]

      case Canary.Repo.aggregate(query, :count) do
        0 ->
          :ok

        _ ->
          :timer.sleep(1000)
          wait_for_oban()
      end
    end

    defp fetch_env() do
      api_base = System.get_env("EVAL_API_BASE")
      api_key = System.get_env("EVAL_API_KEY")

      if api_base == nil || api_key == nil do
        raise "'EVAL_API_BASE' and 'EVAL_API_KEY' are required"
      end

      %{api_base: api_base, api_key: api_key}
    end

    defp encode_yaml(data) do
      schema = "# yaml-language-server: $schema=./spec.schema.json\n"
      schema <> Ymlr.document!(data)
    end
  end

  defmodule Canary.Mock do
    def account() do
      email = "#{random_string()}@example.com"
      password = random_string(12)
      account_name = random_string(8)

      user =
        Canary.Accounts.User
        |> Ash.Changeset.for_create(:mock, %{email: email, hashed_password: password})
        |> Ash.create!()

      Canary.Accounts.Account
      |> Ash.Changeset.for_create(:create, %{name: account_name, user: user})
      |> Ash.create!()
    end

    defp random_string(length \\ 10) do
      :crypto.strong_rand_bytes(length)
      |> Base.url_encode64()
      |> binary_part(0, length)
    end
  end
end
