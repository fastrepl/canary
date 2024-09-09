defmodule Canary.Sources.Event do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :meta, Canary.Sources.EventMeta, allow_nil?: false
  end

  relationships do
    belongs_to :source, Canary.Sources.Source, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [:meta]
      argument :source_id, :uuid, allow_nil?: false
      change manage_relationship(:source_id, :source, type: :append)
    end
  end

  pub_sub do
    prefix "source:event"
    delimiter ":"
    publish :create, ["created", :source_id]
    module CanaryWeb.Endpoint
  end

  code_interface do
    define :create, args: [:source_id, :meta], action: :create
  end

  postgres do
    table "source_events"
    repo Canary.Repo
  end
end
