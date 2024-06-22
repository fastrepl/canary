defmodule Canary.Sources do
  use Ash.Domain

  resources do
    resource Canary.Sources.Snapshot
    resource Canary.Sources.Document
    resource Canary.Sources.Website
  end
end
