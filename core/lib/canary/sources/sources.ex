defmodule Canary.Sources do
  use Ash.Domain

  resources do
    resource Canary.Sources.Source
    resource Canary.Sources.Document
    resource Canary.Sources.Event
  end
end
