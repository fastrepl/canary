defmodule Canary.Index.Document.Webpage do
  @derive Jason.Encoder
  defstruct [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta,
    #
    :title,
    :content
  ]
end

defmodule Canary.Index.Document.Webpage.Meta do
  @derive Jason.Encoder
  defstruct [
    :url,
    :titles
  ]
end

defmodule Canary.Index.Document.GithubIssue do
  @derive Jason.Encoder
  defstruct [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta,
    #
    :title,
    :content
  ]
end

defmodule Canary.Index.Document.GithubDiscussion do
  @derive Jason.Encoder
  defstruct [
    :id,
    :source_id,
    :embedding,
    :tags,
    :meta,
    #
    :title,
    :content
  ]
end
