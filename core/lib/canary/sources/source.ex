defmodule Canary.Sources.Source do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    simple_notifiers: [Canary.Notifiers.Discord]

  require Ash.Query
  require Ecto.Query

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    attribute :last_fetched_at, :utc_datetime, allow_nil?: true

    attribute :state, :atom,
      constraints: [one_of: [:idle, :running, :error]],
      default: :idle,
      allow_nil?: false

    attribute :name, :string, allow_nil?: false
    attribute :overview, Canary.Sources.SourceOverview, allow_nil?: true
    attribute :config, Canary.Type.SourceConfig, allow_nil?: false
  end

  identities do
    identity :unique_name, [:name, :project_id]
  end

  relationships do
    belongs_to :project, Canary.Accounts.Project, allow_nil?: false
    has_many :documents, Canary.Sources.Document
    has_many :events, Canary.Sources.Event
  end

  aggregates do
    count :num_documents, :documents
    max :lastest_event_at, :events, :created_at
  end

  actions do
    defaults [:read, update: [:state, :last_fetched_at, :name, :overview, :config]]

    read :find_with_project_public_key do
      argument :project_public_key, :string, allow_nil?: false
      filter expr(project.public_key == ^arg(:project_public_key))
    end

    create :create do
      primary? true

      accept [:name, :config]
      argument :project_id, :uuid, allow_nil?: false
      change manage_relationship(:project_id, :project, type: :append)
    end

    update :update_last_fetched_at do
      change set_attribute(:last_fetched_at, &DateTime.utc_now/0)
    end

    destroy :destroy do
      primary? true

      change {Ash.Resource.Change.CascadeDestroy, relationship: :documents, action: :destroy}
      change {Ash.Resource.Change.CascadeDestroy, relationship: :events, action: :destroy}
    end

    update :cancel_fetch do
      require_atomic? false

      change set_attribute(:state, :idle)

      change fn changeset, _ctx ->
        %{id: source_id, config: %Ash.Union{type: type}} = changeset.data

        worker =
          case type do
            :webpage -> Canary.Workers.WebpageProcessor
            :github_issue -> Canary.Workers.GithubIssueProcessor
            :github_discussion -> Canary.Workers.GithubDiscussionProcessor
          end
          |> to_string()
          |> String.trim_leading("Elixir.")

        changeset
        |> Ash.Changeset.after_action(fn _, record ->
          result =
            Oban.Job
            |> Ecto.Query.where(worker: ^worker)
            |> Ecto.Query.where([j], json_extract_path(j.args, ["source_id"]) == ^source_id)
            |> Oban.cancel_all_jobs()

          case result do
            {:ok, _} ->
              {:ok, record}

            {:error, error} ->
              IO.inspect(error)
              {:ok, record}
          end
        end)
      end
    end

    update :fetch do
      require_atomic? false

      change set_attribute(:state, :running)
      change set_attribute(:last_fetched_at, &DateTime.utc_now/0)

      change fn changeset, _ctx ->
        %{id: source_id, config: config} = changeset.data

        job =
          case config.type do
            :webpage ->
              Canary.Workers.WebpageProcessor.new(%{source_id: source_id})

            :github_issue ->
              Canary.Workers.GithubIssueProcessor.new(%{source_id: source_id})

            :github_discussion ->
              Canary.Workers.GithubDiscussionProcessor.new(%{source_id: source_id})
          end

        case Oban.insert(job) do
          {:ok, _job} ->
            changeset

          {:error, %{errors: errors}} ->
            changeset
            |> Ash.Changeset.add_error(errors)
        end
      end
    end
  end

  code_interface do
    define :create, args: [:project_id, :name, :config], action: :create
    define :update_state, args: [:state], action: :update
    define :update_last_fetched_at, args: [], action: :update_last_fetched_at
  end

  policies do
    bypass actor_attribute_equals(:super_user, true) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if Canary.Checks.Membership.SourceCreate
    end

    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "sources"
    repo Canary.Repo

    references do
      reference :project, deferrable: :initially
    end
  end
end
