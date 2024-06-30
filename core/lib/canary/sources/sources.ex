defmodule Canary.Sources do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource Canary.Sources.Document
    resource Canary.Sources.Source
  end
end
