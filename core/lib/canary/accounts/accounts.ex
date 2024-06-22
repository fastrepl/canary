defmodule Canary.Accounts do
  use Ash.Domain

  resources do
    resource Canary.Accounts.User
    resource Canary.Accounts.Token
    resource Canary.Accounts.Account
    resource Canary.Accounts.AccountUser
  end
end
