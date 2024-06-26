defmodule Canary.Accounts.User do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  actions do
    defaults [:read]

    create :mock, accept: [:email, :hashed_password]
  end

  relationships do
    many_to_many :accounts, Canary.Accounts.Account do
      through Canary.Accounts.AccountUser
    end
  end

  changes do
    change Canary.Accounts.Changes.InitAccount, on: [:create]
  end

  identities do
    identity :unique_email, [:email]
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      enabled? true
      token_resource Canary.Accounts.Token
      signing_secret Canary.Accounts.Secrets
    end
  end

  postgres do
    table "users"
    repo Canary.Repo
  end
end
