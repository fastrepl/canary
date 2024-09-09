defmodule Canary.Change.UpdateFromIndex do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, record ->
      case record
           |> Canary.Index.Document.from()
           |> Canary.Index.update_document() do
        {:ok, _} -> {:ok, record}
        error -> error
      end
    end)
  end
end
