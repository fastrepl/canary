defmodule Canary.Accounts.UserIdentity do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity],
    domain: Canary.Accounts

  user_identity do
    user_resource Canary.Accounts.User
  end

  postgres do
    table "user_identities"
    repo Canary.Repo
  end
end
