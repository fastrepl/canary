defmodule Canary.Index.Document.Webpage do
  @common [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta
  ]

  @derive Jason.Encoder
  defstruct @common ++ [:title, :content]
end

defmodule Canary.Index.Document.Webpage.Meta do
  @derive Jason.Encoder
  defstruct [:url]
end

defmodule Canary.Index.Document.GithubIssue do
  @common [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta
  ]

  @derive Jason.Encoder
  defstruct @common ++ [:title, :content]
end

defmodule Canary.Index.Document.GithubIssue.Meta do
  @derive Jason.Encoder
  defstruct [:url]
end

defmodule Canary.Index.Document.GithubDiscussion do
  @common [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta
  ]

  @derive Jason.Encoder
  defstruct @common ++ [:title, :content]
end

defmodule Canary.Index.Document.GithubDiscussion.Meta do
  @derive Jason.Encoder
  defstruct [:url]
end
