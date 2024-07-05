defmodule Canary.Github.Repo do
  use Ash.Resource,
    domain: Canary.Github,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key :id
    attribute :full_name, :string, allow_nil?: false
  end

  identities do
    identity :unique_repo, [:app_id, :full_name]
  end

  relationships do
    belongs_to :app, Canary.Github.App
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      upsert? true
      upsert_identity :unique_repo
      upsert_fields :replace_all

      argument :app, :map, allow_nil?: true
      argument :full_name, :string, allow_nil?: false

      change manage_relationship(:app, :app, type: :append)
      change set_attribute(:full_name, expr(^arg(:full_name)))
    end

    action :delete do
      argument :app, :map, allow_nil?: true
      argument :full_names, {:array, :string}, allow_nil?: false

      run fn %{arguments: args}, _ ->
        result =
          __MODULE__
          |> Ash.Query.filter(app_id == ^args.app.id and full_name in ^args.full_names)
          |> Ash.bulk_destroy(:destroy, %{})

        case result do
          %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
          _ -> {:ok, result}
        end
      end
    end
  end

  code_interface do
    define :create, args: [:app, :full_name], action: :create
    define :delete, args: [:app, :full_names], action: :delete
  end

  postgres do
    table "github_repos"
    repo Canary.Repo

    references do
      reference :app, on_delete: :delete
    end
  end
end
