defmodule Canary.Accounts do
  use Ash.Domain

  resources do
    resource Canary.Accounts.User
    resource Canary.Accounts.Token
    resource Canary.Accounts.Account
    resource Canary.Accounts.AccountUser
    resource Canary.Accounts.UserIdentity
    resource Canary.Accounts.Billing
    resource Canary.Accounts.Invite
  end
end
