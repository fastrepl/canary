defmodule Canary.Interactions.ClientSource do
  use Ash.Resource,
    domain: Canary.Interactions,
    data_layer: AshPostgres.DataLayer

  relationships do
    belongs_to :client, Canary.Interactions.Client, primary_key?: true, allow_nil?: false
    belongs_to :source, Canary.Sources.Source, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  postgres do
    table "client_sources"
    repo Canary.Repo

    references do
      reference :client, on_delete: :delete
      reference :source, on_delete: :delete
    end
  end
end
