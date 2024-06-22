defmodule Canary.Clients do
  use Ash.Domain

  resources do
    resource Canary.Clients.Website
  end
end
