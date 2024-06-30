defmodule Canary.Sources.Changes.CreateChunksFromDocument do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.before_transaction(fn changeset ->
      texts =
        changeset
        |> Ash.Changeset.get_argument(:content)
        |> Canary.Reader.chunk_markdown()

      case Canary.AI.embedding(%{input: texts}) do
        {:ok, embeddings} ->
          chunks =
            Enum.zip(texts, embeddings)
            |> Enum.map(fn {content, embedding} -> %{content: content, embedding: embedding} end)

          changeset
          |> Ash.Changeset.set_context(%{chunks: chunks})

        _ ->
          changeset
          |> Ash.Changeset.add_error("embedding failed")
      end
    end)
    |> Ash.Changeset.after_action(fn changeset, doc ->
      result =
        changeset.context.chunks
        |> Enum.map(&Map.put(&1, :document, doc))
        |> Ash.bulk_create(Canary.Sources.Chunk, :create,
          return_records?: false,
          return_errors?: true
        )

      case result do
        %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
        _ -> {:ok, doc}
      end
    end)
  end
end
