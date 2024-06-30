defmodule Canary.Sources do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource Canary.Sources.Source
    resource Canary.Sources.Document
    resource Canary.Sources.Chunk
  end
end
