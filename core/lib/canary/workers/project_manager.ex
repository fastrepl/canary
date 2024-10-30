defmodule Canary.Workers.ProjectManager do
  use Oban.Worker, queue: :default, max_attempts: 1

  @impl true
  def perform(%Oban.Job{}) do
    if Application.get_env(:canary, :env) != :prod do
      :ok
    else
      with {:ok, rows} <- Canary.Analytics.Tinybird.query(:all_project_ids),
           {:ok, projects} = Ash.read(Canary.Accounts.Project) do
        all_project_ids = rows |> Enum.map(& &1["project_id"])
        valid_project_ids = projects |> Enum.map(& &1.id)

        pruning_jobs =
          (all_project_ids -- valid_project_ids)
          |> Enum.map(&Canary.Workers.TinybirdPruner.new(%{project_id: &1}))

        alias_jobs =
          valid_project_ids
          |> Enum.map(&Canary.Workers.QueryAliases.new(%{project_id: &1}))

        Oban.insert_all(pruning_jobs ++ alias_jobs)

        :ok
      end
    end
  end
end
