defmodule Canary.Index.Document.Shared do
  def top_level_fields() do
    [
      :id,
      :source_id,
      :embedding,
      :tags,
      :is_empty_tags,
      :meta
    ]
  end

  def meta_fields() do
    [
      :url,
      :document_id,
      :is_parent
    ]
  end
end

defmodule Canary.Index.Document.Webpage do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.top_level_fields() ++ [:title, :content]
end

defmodule Canary.Index.Document.Webpage.Meta do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.meta_fields()
end

defmodule Canary.Index.Document.GithubIssue do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.top_level_fields() ++ [:title, :content]
end

defmodule Canary.Index.Document.GithubIssue.Meta do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.meta_fields()
end

defmodule Canary.Index.Document.GithubDiscussion do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.top_level_fields() ++ [:title, :content]
end

defmodule Canary.Index.Document.GithubDiscussion.Meta do
  alias Canary.Index.Document.Shared

  @derive Jason.Encoder
  defstruct Shared.meta_fields()
end
