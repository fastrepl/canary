defmodule Canary.Workers.TinybirdPruner do
  use Oban.Worker, queue: :tinybird, max_attempts: 1

  @impl true
  def perform(%Oban.Job{args: %{"project_id" => project_id}}) do
    Canary.Analytics.Tinybird.sources()
    |> Enum.each(&Canary.Analytics.Tinybird.delete_by_project_id(&1, project_id))

    :ok
  end
end
