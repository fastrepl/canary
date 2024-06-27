defmodule Canary.Workers.Embedder do
  use Oban.Worker, queue: :embedder, max_attempts: 5

  alias Canary.Sources.Document

  @impl true
  def perform(%Oban.Job{args: %{"document_id" => id}}) do
    case Ash.get(Document, id) do
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

  defp process(%Document{} = doc) do
    model = Application.get_env(:canary, :text_embedding_model)
    input = [Canary.Renderable.render(doc)]

    with {:ok, [embedding]} = Canary.AI.embedding(%{model: model, input: input}),
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
