defmodule Canary.Accounts.Invite do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :email, :string, allow_nil?: false
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    read :not_expired do
      filter expr(created_at > ago(48, :hour))
    end

    create :create do
      accept [:email]
      argument :account_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)

      change after_action(fn changeset, record, _ctx ->
               Canary.UserNotifier.MemberInvite.send(record.email)
               {:ok, record}
             end)
    end
  end

  policies do
    bypass actor_attribute_equals(:super_user, true) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if Canary.Checks.Filter.InviteAccess
    end

    policy action_type(:destroy) do
      authorize_if Canary.Checks.Filter.InviteAccess
    end

    policy action_type(:create) do
      authorize_if Canary.Checks.Membership.TeamInvite
    end

    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "account_invites"
    repo Canary.Repo
  end
end
