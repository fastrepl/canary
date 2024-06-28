defmodule Canary.Sessions.Message do
  use Ash.Resource,
    domain: Canary.Sessions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    attribute :session_id, :uuid, allow_nil?: false

    attribute :role, :atom, constraints: [one_of: [:user, :assistant]], allow_nil?: false
    attribute :content, :string, allow_nil?: false
  end

  actions do
    defaults [:read]

    create :add_user do
      argument :session, :map, allow_nil?: false
      argument :content, :string, allow_nil?: false
      change set_attribute(:role, :user)
      change set_attribute(:content, expr(^arg(:content)))
      change manage_relationship(:session, :session, type: :append)
    end

    create :add_assistant do
      argument :session, :map, allow_nil?: false
      argument :content, :string, allow_nil?: false
      change set_attribute(:role, :assistant)
      change set_attribute(:content, expr(^arg(:content)))
      change manage_relationship(:session, :session, type: :append)
    end
  end

  code_interface do
    define :add_user, args: [:session, :content], action: :add_user
    define :add_assistant, args: [:session, :content], action: :add_assistant
  end

  relationships do
    belongs_to :session, Canary.Sessions.Session
  end

  postgres do
    table "session_messages"
    repo Canary.Repo
  end
end
