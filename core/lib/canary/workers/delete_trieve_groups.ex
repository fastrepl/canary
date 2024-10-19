defmodule Canary.Workers.DeleteTrieveGroup do
  use Oban.Worker,
    queue: :trieve,
    max_attempts: 3

  alias Canary.Index.Trieve

  @impl true
  def perform(%Oban.Job{args: %{"tracking_id" => id}}) do
    case Trieve.Client.delete_group(id) do
      :ok -> :ok
      {:error, %{"message" => "Not Found" <> _}} -> :ok
      {:error, error} -> {:error, error}
    end
  end
end
