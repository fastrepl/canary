defmodule Canary.Github.Changes.CreateRepos do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_action(fn changeset, app ->
      repos = changeset |> Ash.Changeset.get_argument(:repos)

      case repos do
        repos when is_list(repos) and length(repos) > 0 ->
          result =
            repos
            |> Enum.map(&%{app: app, full_name: &1})
            |> Ash.bulk_create(Canary.Github.Repo, :create)

          case result do
            %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
            _ -> {:ok, app}
          end

        _ ->
          {:ok, app}
      end
    end)
  end
end
