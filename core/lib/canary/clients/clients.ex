defmodule Canary.Clients do
  use Ash.Domain

  resources do
    resource Canary.Clients.Client
    resource Canary.Clients.ClientSource
  end
end
