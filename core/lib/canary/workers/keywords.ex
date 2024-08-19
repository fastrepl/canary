defmodule Canary.Workers.Keywords do
  use Oban.Worker, queue: :keyword, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: %{"document_id" => id}}) do
    case Ash.get(Canary.Sources.Document, id) do
      {:ok, doc} -> run(doc)
      {:error, _} -> :ok
    end
  end

  def run(doc) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model_background)

    messages = [
      system_message(),
      %{role: "user", content: "Document: #{doc.content}"}
    ]

    with {:ok, completion} <- Canary.AI.chat(%{model: chat_model, messages: messages}),
         {:ok, _} <- Canary.Sources.Document.update_kewords(doc, transform(completion)) do
      :ok
    end
  end

  defp system_message() do
    %{
      role: "system",
      content: """
      You are a world class techincal writer.
      Your job is to analyze existing document, and return a structured response like below:

      <analysis>
      <keywords>KEYWORD_1,KEYWORD_2,KEYWORD_3</keywords>
      </analysis>

      IMPORTANT NOTES:
      - <keywords></keywords> should contain comma separated list of keywords. MAX 20 keywords are allowed.
      - Each "keyword" should be one or two words. It will be used to run keyword based search.
      - Start with important, domain specific, or frequently used words in the document.

      Do not include any other text, just respond with the XML-like format that I provided.
      If user's query is totally nonsense, just return <analysis></analysis>.
      """
    }
  end

  defp transform(completion) do
    ~r/<keywords>(.*?)<\/keywords>/s
    |> Regex.scan(completion, capture: :all_but_first)
    |> Enum.flat_map(fn [keywords] ->
      keywords
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.downcase/1)
    end)
    |> Enum.uniq()
  end
end
