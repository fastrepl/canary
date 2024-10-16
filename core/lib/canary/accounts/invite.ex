defmodule Canary.Accounts.Invite do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :email, :string, allow_nil?: false
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:account])
    end

    read :not_expired do
      filter expr(created_at > ago(48, :hour))
    end

    create :create do
      argument :account_id, :uuid, allow_nil?: false
      argument :email, :string, allow_nil?: false

      change after_action(fn changeset, record, _ctx ->
               Canary.UserNotifier.MemberInvite.send(record.email)
               {:ok, record}
             end)

      change set_attribute(:email, arg(:email))
      change manage_relationship(:account_id, :account, type: :append)
    end
  end

  postgres do
    table "account_invites"
    repo Canary.Repo
  end
end
