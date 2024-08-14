defmodule Canary.Workers.Summary do
  use Oban.Worker, queue: :summary, max_attempts: 3

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
         %{keywords: keywords, summary: summary} <- transform(completion),
         {:ok, _} <- Canary.Sources.Document.update_summary(doc, keywords, summary) do
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
      <summary>SUMMARY</summary>
      <keywords>KEYWORD_1,KEYWORD_2,KEYWORD_3</keywords>
      </analysis>

      IMPORTANT NOTES:
      - <keywords></keywords> should contain comma separated list of keywords. MAX 30 keywords are allowed. Start with common or important words in the document.
      - Each "keyword" should be one or two words. It will be used to run keyword based search.
      - There should be only one "<summary>" and "<keywords>" within the "<analysis>".
      - The "summary" is one or two sentences that describe main points of the document.

      Do not include any other text, just respond with the XML-like format that I provided.
      If user's query is totally nonsense, just return <analysis></analysis>.
      """
    }
  end

  defp transform(completion) do
    keywords =
      ~r/<keywords>(.*?)<\/keywords>/s
      |> Regex.scan(completion, capture: :all_but_first)
      |> Enum.flat_map(fn [keywords] ->
        keywords |> String.split(",") |> Enum.map(&String.trim/1)
      end)

    summary =
      ~r/<summary>(.*?)<\/summary>/s
      |> Regex.scan(completion, capture: :all_but_first)
      |> Enum.map(fn [query] -> String.trim(query) end)
      |> Enum.at(0, nil)

    %{keywords: keywords, summary: summary}
  end
end
