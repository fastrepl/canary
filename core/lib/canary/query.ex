defmodule Canary.Query.Understander do
  @callback run(String.t()) :: {:ok, list(String.t())} | {:error, any()}

  def run(query), do: impl().run(query)
  defp impl(), do: Canary.Query.Understander.LLM
end

defmodule Canary.Query.Understander.LLM do
  @behaviour Canary.Query.Understander

  def run(query) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model)

    messages = [
      system_message(),
      %{role: "user", content: "User: #{query}"}
    ]

    case Canary.AI.chat(%{model: chat_model, messages: messages}) do
      {:ok, result} -> {:ok, parse(result)}
      error -> error
    end
  end

  defp system_message() do
    %{
      role: "system",
      content: """
      You are a techincal support engineer. Based on the user's query, write a structured query to find relevant resources from the internal knowledge base.

      Your output should strictly follow this format:

      <queries>
      <query><FIRST_QUERY></query>
      <query><SECOND_QUERY></query>
      <query><THIRD_QUERY></query>
      </queries>

      IMPORTANT NOTES:
      - There can be multiple "<query>" within the "<queries>". Max 3 queries are allowed.
      - Inside each "<query>", you should only include query that consists of 1~3 words that will be used to run keyword based search.
      - Keywords in the user's query might be better rephrased for better search results.

      I know you don't have enough context to answer the question, but this guess is useful to narrow down the search space.

      Do not include any other text, just respond with the XML-like format that I provided.
      If user's query is totally nonsense, just return <queries></queries>.
      """
    }
  end

  defp parse(text) do
    pattern = ~r/<query>(.*?)<\/query>/s

    pattern
    |> Regex.scan(text, capture: :all_but_first)
    |> Enum.map(fn [query] -> String.trim(query) end)
  end
end
