defmodule Canary.Keywords do
  alias Canary.Sources.Document
  import Canary.Native, only: [extract_keywords: 2]

  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  def extract(%Document{meta: %Ash.Union{value: meta}, chunks: chunks}, opts) do
    keywords_from_title = extract(meta, opts)

    keywords_from_chunks =
      chunks
      |> Enum.map(fn %Ash.Union{value: value} -> value.content end)
      |> Enum.join("\n")
      |> extract_keywords(opts[:max])

    Enum.uniq(keywords_from_title ++ keywords_from_chunks)
  end

  def extract(%Webpage.DocumentMeta{title: title}, _opts) do
    extract_keywords(title, 5)
  end

  def extract(%GithubIssue.DocumentMeta{title: title}, _opts) do
    extract_keywords(title, 5)
  end

  def extract(%GithubDiscussion.DocumentMeta{title: title}, _opts) do
    extract_keywords(title, 5)
  end
end
