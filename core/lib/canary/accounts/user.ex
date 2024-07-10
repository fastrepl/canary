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

    if Application.compile_env(:canary, :env) == :test do
      create :mock, accept: [:email, :hashed_password]
    end

    create :register_with_github do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false

      upsert? true
      upsert_identity :email

      change AshAuthentication.GenerateTokenChange
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)
        Ash.Changeset.change_attributes(changeset, Map.take(user_info, ["email"]))
      end
    end
  end

  relationships do
    many_to_many :accounts, Canary.Accounts.Account do
      through Canary.Accounts.AccountUser
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end

      if Application.compile_env(:canary, :github) do
        github do
          client_id Canary.Accounts.Secrets
          redirect_uri Canary.Accounts.Secrets
          client_secret Canary.Accounts.Secrets
        end
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
