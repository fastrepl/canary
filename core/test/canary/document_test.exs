defmodule Canary.Test.Document do
  use Canary.DataCase
  import Canary.AccountsFixtures

  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue

  describe "webpage" do
    test "create" do
      account = account_fixture()
      project = Canary.Accounts.Project.create!(account.id, "project")

      source =
        Canary.Sources.Source
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_action(
          :create,
          %{
            project_id: project.id,
            name: "Docs",
            config: %Ash.Union{type: :webpage, value: %Webpage.Config{}}
          },
          authorize?: false
        )
        |> Ash.create!()

      doc =
        Canary.Sources.Document
        |> Ash.Changeset.for_create(
          :create_webpage,
          %{
            source_id: source.id,
            fetcher_result: %Webpage.FetcherResult{
              url: "https://example.com/",
              html: "<body><h1>hello</h1></body>",
              items: [
                %Canary.Scraper.Item{id: nil, level: 1, title: "hello", content: "<h1>hello</h1>"}
              ]
            }
          },
          authorize?: false
        )
        |> Ash.create!()

      assert doc.meta.type == :webpage
      assert doc.meta.value.url == "https://example.com"
      assert length(doc.chunks) == 1
      %Ash.Union{value: chunk} = doc.chunks |> Enum.at(0)
      assert chunk.url == "https://example.com"
    end

    test "destroy" do
      account = account_fixture()
      project = Canary.Accounts.Project.create!(account.id, "project")

      source =
        Canary.Sources.Source
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_action(
          :create,
          %{
            project_id: project.id,
            name: "Docs",
            config: %Ash.Union{type: :webpage, value: %Webpage.Config{}}
          },
          authorize?: false
        )
        |> Ash.create!()

      Canary.Sources.Document
      |> Ash.Changeset.for_create(:create_webpage, %{
        source_id: source.id,
        fetcher_result: %Webpage.FetcherResult{
          url: "https://example.com/",
          html: "<body><h1>hello</h1></body>",
          items: [
            %Canary.Scraper.Item{id: nil, level: 1, title: "hello", content: "<h1>hello</h1>"}
          ]
        }
      })
      |> Ash.create!()

      docs = source |> Ash.load!(:documents) |> Map.get(:documents)
      assert length(docs) == 1
      Ash.bulk_destroy(docs, :destroy, %{}, return_errors?: true)

      docs = source |> Ash.load!(:documents) |> Map.get(:documents)
      assert length(docs) == 0
    end
  end

  describe "github issue" do
    test "create" do
      account = account_fixture()
      project = Canary.Accounts.Project.create!(account.id, "project")

      source =
        Canary.Sources.Source
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_action(
          :create,
          %{
            project_id: project.id,
            name: "Docs",
            config: %Ash.Union{type: :webpage, value: %Webpage.Config{}}
          },
          authorize?: false
        )
        |> Ash.create!()

      fetcher_results = [
        %GithubIssue.FetcherResult{
          node_id: "node_id",
          title: "title",
          content: "content",
          url: "url",
          created_at: DateTime.utc_now(),
          author_name: "author_name",
          author_avatar_url: "author_avatar_url",
          comment: false,
          closed: false
        }
      ]

      doc =
        Canary.Sources.Document
        |> Ash.Changeset.for_create(:create_github_issue, %{
          source_id: source.id,
          fetcher_results: fetcher_results
        })
        |> Ash.create!()

      assert doc.meta.type == :github_issue
    end
  end
end
