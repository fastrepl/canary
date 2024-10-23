defmodule Canary.Accounts.User do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    simple_notifiers: [Canary.Notifiers.Discord]

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: true, sensitive?: true

    attribute :selected_account_id, :uuid, allow_nil?: true
    attribute :selected_project_id, :uuid, allow_nil?: true
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: true

    many_to_many :accounts, Canary.Accounts.Account do
      through Canary.Accounts.AccountUser
    end
  end

  actions do
    defaults [:read, :destroy, update: [:email, :selected_account_id, :selected_project_id]]

    if Application.compile_env(:canary, :env) != :prod do
      create :mock, accept: [:email, :hashed_password]
    end

    create :register_with_github do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false

      upsert? true
      upsert_identity :unique_email

      change AshAuthentication.GenerateTokenChange
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)
        Ash.Changeset.change_attributes(changeset, Map.take(user_info, ["email"]))
      end
    end
  end

  identities do
    identity :unique_email, [:email], eager_check_with: Canary.Accounts
  end

  authentication do
    strategies do
      password :password do
        identity_field :email

        resettable do
          sender Canary.UserNotifier.ResetPassword
        end
      end

      github :github do
        client_id Canary.Accounts.Secrets
        redirect_uri Canary.Accounts.Secrets
        client_secret Canary.Accounts.Secrets
      end
    end

    tokens do
      enabled? true
      token_resource Canary.Accounts.Token
      signing_secret Canary.Accounts.Secrets
    end

    add_ons do
      confirmation :confirm_new_user do
        monitor_fields [:email]
        confirm_on_create? true
        confirm_on_update? true
        confirm_action_name :confirm_new_user
        sender Canary.UserNotifier.NewUserEmailConfirmation
      end
    end
  end

  postgres do
    table "users"
    repo Canary.Repo
  end
end
