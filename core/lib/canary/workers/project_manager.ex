defmodule Canary.Workers.ProjectManager do
  use Oban.Worker, queue: :default, max_attempts: 1

  @impl true
  def perform(%Oban.Job{}) do
    if Application.get_env(:canary, :env) != :prod do
      :ok
    else
      {:ok, projects} = Ash.read(Canary.Accounts.Project)

      projects
      |> Enum.flat_map(fn %{id: id} ->
        [
          Canary.Workers.TinybirdPruner.new(%{project_id: id}),
          Canary.Workers.QueryAliases.new(%{project_id: id})
        ]
      end)
      |> Oban.insert_all()

      :ok
    end
  end
end
