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

    attribute :count_ask, :integer, allow_nil?: false, default: 0
    attribute :count_search, :integer, allow_nil?: false, default: 0
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

    update :update_stripe_customer do
      require_atomic? false
      argument :stripe_customer, :map, allow_nil?: true

      change {Canary.Accounts.Changes.StructToMap, attribute: :stripe_customer}
      change set_attribute(:stripe_customer, expr(^arg(:stripe_customer)))
    end

    update :update_stripe_subscription do
      require_atomic? false
      argument :stripe_subscription, :map, allow_nil?: true

      change {Canary.Accounts.Changes.StructToMap, attribute: :stripe_subscription}
      change set_attribute(:stripe_subscription, expr(^arg(:stripe_subscription)))
    end

    update :increment_ask do
      change atomic_update(:count_ask, expr(count_ask + 1))
    end

    update :increment_search do
      change atomic_update(:count_search, expr(count_search + 1))
    end

    update :reset_ask do
      change atomic_update(:count_ask, expr(0))
    end

    update :reset_search do
      change atomic_update(:count_search, expr(0))
    end
  end

  code_interface do
    define :update_stripe_customer,
      args: [:stripe_customer],
      action: :update_stripe_customer

    define :update_stripe_subscription,
      args: [:stripe_subscription],
      action: :update_stripe_subscription

    define :increment_ask, args: [], action: :increment_ask
    define :increment_search, args: [], action: :increment_search
    define :reset_ask, args: [], action: :reset_ask
    define :reset_search, args: [], action: :reset_search
  end

  postgres do
    table "billings"
    repo Canary.Repo

    references do
      reference :account, on_delete: :nothing
    end
  end
end
