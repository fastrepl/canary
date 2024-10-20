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
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
  end

  calculations do
    calculate :membership, :atom, {
      Canary.Accounts.MembershipCalculation,
      stripe_subscription_attribute: :stripe_subscription
    }
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :account, :map, allow_nil?: false
      argument :stripe_customer, :map, allow_nil?: true
      argument :stripe_subscription, :map, allow_nil?: true

      change manage_relationship(:account, :account, type: :append)
      change set_attribute(:stripe_customer, arg(:stripe_customer))
      change set_attribute(:stripe_subscription, arg(:stripe_subscription))
    end

    update :update_stripe_customer do
      argument :stripe_customer, :map, allow_nil?: true

      change {Canary.Accounts.Changes.StructToMap, argument: :stripe_customer}
      change set_attribute(:stripe_customer, arg(:stripe_customer))
    end

    update :update_stripe_subscription do
      argument :stripe_subscription, :map, allow_nil?: true

      change {Canary.Accounts.Changes.StructToMap, argument: :stripe_subscription}
      change set_attribute(:stripe_subscription, arg(:stripe_subscription))
    end

    update :set_ask do
      change set_attribute(:count_ask, 0)
    end

    update :set_search do
      change set_attribute(:count_search, 0)
    end
  end

  code_interface do
    define :update_stripe_customer,
      args: [:stripe_customer],
      action: :update_stripe_customer

    define :update_stripe_subscription,
      args: [:stripe_subscription],
      action: :update_stripe_subscription

    define :set_ask, args: [], action: :set_ask
    define :set_search, args: [], action: :set_search
  end

  postgres do
    table "billings"
    repo Canary.Repo

    references do
      reference :account, on_delete: :nothing
    end
  end
end
