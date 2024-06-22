defmodule Canary.Accounts.Token do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "tokens"
    repo Canary.Repo
  end
end
