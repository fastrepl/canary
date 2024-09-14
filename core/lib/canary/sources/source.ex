defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :name, :string, allow_nil?: false
    attribute :overview, Canary.Sources.SourceOverview, allow_nil?: true
    attribute :config, Canary.Type.SourceConfig, allow_nil?: false
  end

  identities do
    identity :unique_name, [:name, :account_id]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
    has_many :documents, Canary.Sources.Document
    has_many :events, Canary.Sources.Event
  end

  aggregates do
    count :num_documents, :documents
    max :lastest_event_at, :events, :created_at
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [:name, :config]
      argument :account_id, :uuid, allow_nil?: false
      change manage_relationship(:account_id, :account, type: :append)
    end

    update :update do
      primary? true
      # unions do not support atomic updates
      require_atomic? false

      accept [:name, :config, :overview]
    end

    update :update_overview do
      require_atomic? false

      change fn changeset, _ ->
        id = Ash.Changeset.get_data(changeset, :id)

        documents =
          Canary.Sources.Document
          |> Ash.Query.filter(source_id == ^id)
          |> Ash.read!()

        chunks =
          documents
          |> Enum.flat_map(fn %Canary.Sources.Document{chunks: chunks} ->
            Enum.map(chunks, fn %Ash.Union{value: value} -> value end)
          end)

        titles = Enum.map(chunks, fn %{title: title} -> title end)

        keywords =
          chunks
          |> Enum.map(fn %{content: content} -> content end)
          |> Enum.join("\n")
          |> then(&Canary.Native.extract_keywords(&1, length(documents) * 20))

        overview = %Canary.Sources.SourceOverview{titles: titles, keywords: keywords}

        changeset
        |> Ash.Changeset.change_attribute(:overview, overview)
      end
    end

    destroy :destroy do
      primary? true

      change {Ash.Resource.Change.CascadeDestroy, relationship: :documents, action: :destroy}
      change {Ash.Resource.Change.CascadeDestroy, relationship: :events, action: :destroy}
    end
  end

  code_interface do
    define :create, args: [:account_id, :name, :config], action: :create
  end

  postgres do
    table "sources"
    repo Canary.Repo
  end
end
