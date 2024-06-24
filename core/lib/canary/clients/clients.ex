defmodule Canary.Clients do
  use Ash.Domain

  resources do
    resource Canary.Clients.Client
  end
end
