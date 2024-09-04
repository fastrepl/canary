defmodule Canary.Accounts.SubdomainConfig do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :name, :string, allow_nil?: false
    attribute :logo_url, :string, allow_nil?: true
  end
end
