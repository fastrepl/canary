defmodule Canary.Sources do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource Canary.Sources.Source
    resource Canary.Sources.Document
  end
end
