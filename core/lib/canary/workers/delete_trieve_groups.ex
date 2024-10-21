defmodule Canary.Workers.DeleteTrieveGroup do
  use Oban.Worker, queue: :trieve, max_attempts: 3

  alias Canary.Index.Trieve

  @impl true
  def perform(%Oban.Job{
        args: %{
          "dataset_tracking_id" => dataset_tracking_id,
          "group_tracking_id" => group_tracking_id
        }
      }) do
    case Trieve.client(dataset_tracking_id) |> Trieve.delete_group(group_tracking_id) do
      :ok -> :ok
      {:error, %{"message" => "Not Found" <> _}} -> :ok
      {:error, error} -> {:error, error}
    end
  end
end
