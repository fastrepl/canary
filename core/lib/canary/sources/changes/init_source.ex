defmodule Canary.Sources.Changes.InitSource do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_transaction(fn _changeset, result ->
      case result do
        {:ok, source} ->
          Canary.Workers.Fetcher.new(%{source_id: source.id}) |> Oban.insert()
          {:ok, source}

        error ->
          error
      end
    end)
  end
end
