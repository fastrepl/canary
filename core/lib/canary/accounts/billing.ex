defmodule Canary.Accounts.Billing do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    # https://docs.stripe.com/api/customers/object
    attribute :stripe_customer, :map, allow_nil?: true

    # https://docs.stripe.com/api/subscriptions/object
    attribute :stripe_subscription, :map, allow_nil?: true
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  actions do
    defaults [:read]

    create :create do
      argument :account, :map, allow_nil?: false
      argument :stripe_customer, :map, allow_nil?: true
      argument :stripe_subscription, :map, allow_nil?: true

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:stripe_customer, expr(^arg(:stripe_customer)))
      change set_attribute(:stripe_subscription, expr(^arg(:stripe_subscription)))
    end

    update :update do
      argument :stripe_customer, :map, allow_nil?: true
      argument :stripe_subscription, :map, allow_nil?: true

      change set_attribute(:stripe_customer, expr(^arg(:stripe_customer)))
      change set_attribute(:stripe_subscription, expr(^arg(:stripe_subscription)))
    end
  end

  postgres do
    table "billings"
    repo Canary.Repo

    references do
      reference :account, on_delete: :nothing
    end
  end
end
