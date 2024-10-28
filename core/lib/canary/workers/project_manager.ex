defmodule Canary.Workers.ProjectManager do
  use Oban.Worker, queue: :default, max_attempts: 1

  @impl true
  def perform(%Oban.Job{}) do
    if Application.get_env(:canary, :env) != :prod do
      :ok
    else
      {:ok, projects} = Ash.read(Canary.Accounts.Project)

      pruner_jobs =
        projects
        |> Enum.map(&Canary.Workers.TinybirdPruner.new(%{account_id: &1.id}))

      alias_jobs =
        projects
        |> Enum.map(&Canary.Workers.QueryAliases.new(%{project_id: &1.id}))

      Oban.insert_all(pruner_jobs ++ alias_jobs)

      :ok
    end
  end
end
