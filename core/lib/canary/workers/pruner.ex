defmodule Canary.Workers.Pruner do
  use Oban.Worker, queue: :default, max_attempts: 1

  @impl true
  def perform(%Oban.Job{}) do
    if Application.get_env(:canary, :env) != :prod do
      :ok
    else
      {:ok, projects} = Ash.read(Canary.Accounts.Project)

      projects
      |> Enum.map(&Canary.Workers.TinybirdPruner.new(%{account_id: &1.id}))
      |> Oban.insert_all()

      :ok
    end
  end
end
