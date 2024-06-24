defmodule Canary.Workers.Document do
  use Oban.Worker, queue: :embedding, max_attempts: 5

  def perform(%Oban.Job{args: %{"document_id" => document_id}}) do
    case Canary.Sources.Document |> Ash.get(document_id) do
      {:error, _} ->
        :ok

      {:ok, doc} ->
        if doc.content_embedding do
          :ok
        else
          process(doc)
        end
    end
  end

  defp process(doc) do
    model = Application.get_env(:canary, :text_embedding_model)

    with {:ok, [embedding]} = Canary.AI.embedding(%{model: model, input: [doc.content]}),
         {:ok, _} <-
           doc
           |> Ash.Changeset.for_update(:set_embedding, %{embedding: embedding})
           |> Ash.update() do
      :ok
    else
      error -> error
    end
  end
end
