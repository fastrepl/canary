defmodule Canary.Interactions.Feedback do
  use Ash.Resource,
    domain: Canary.Interactions,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  postgres do
    table "feedbacks"
    repo Canary.Repo
  end
end
