defmodule Canary.Query.UnderstanderResult do
  defstruct [:query, :keywords]
  @type t :: %__MODULE__{query: String.t(), keywords: list(String.t())}
end

defmodule Canary.Query.Understander do
  @callback run(String.t(), String.t()) ::
              {:ok, Canary.Query.UnderstanderResult.t()} | {:error, any()}

  def run(query, keywords), do: impl().run(query, keywords)
  defp impl(), do: Canary.Query.Understander.LLM
end

defmodule Canary.Query.Understander.LLM do
  @behaviour Canary.Query.Understander

  @keywords_section "Keywords extracted from documents"

  def run(query, keywords) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model)

    messages = [
      system_message(),
      %{
        role: "user",
        content:
          "## #{@keywords_section}\n#{Enum.join(keywords, ", ")}\n\n\n## User query\n#{query}"
      }
    ]

    case Canary.AI.chat(%{model: chat_model, messages: messages}) do
      {:ok, analysis} -> {:ok, parse(query, analysis)}
      error -> error
    end
  end

  defp system_message() do
    %{
      role: "system",
      content: """
      You are a world class techincal support engineer.
      Your job is to analyze the user's query and return a structured response like below:

      <analysis>
      <query>QUERY</query>
      <keywords>KEYWORD_1,KEYWORD_2,KEYWORD_3</keywords>
      </analysis>

      IMPORTANT NOTES:
      - <keywords></keywords> should contain comma separated list of keywords. MAX 3 keywords are allowed.
      - Each "keyword" should be one or two words. It will be used to run keyword based search. User '#{@keywords_section}' section for inspiration.
      - The "query" is typo-corrected version of the user's raw query for better search results, with minimal formatting applied.
      - Do not omit prepositions or details that are not mentioned in the user's query.

      Do not include any other text, just respond with the XML-like format that I provided.
      If user's query is totally nonsense, just return <analysis></analysis>.
      """
    }
  end

  defp parse(original_query, completion) do
    keywords =
      ~r/<keywords>(.*?)<\/keywords>/s
      |> Regex.scan(completion, capture: :all_but_first)
      |> Enum.flat_map(fn [keywords] ->
        keywords |> String.split(",") |> Enum.map(&String.trim/1)
      end)

    query =
      ~r/<query>(.*?)<\/query>/s
      |> Regex.scan(completion, capture: :all_but_first)
      |> Enum.map(fn [query] -> String.trim(query) end)
      |> Enum.at(0, nil)

    %Canary.Query.UnderstanderResult{keywords: keywords, query: query || original_query}
  end
end
