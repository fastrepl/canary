defmodule Canary.Query do
  defstruct [:text, :embedding]
  @type t :: %__MODULE__{text: String.t(), embedding: list(float())}
end

defmodule Canary.Query.Understander do
  @callback run(String.t()) :: {:ok, list(Canary.Query.t())} | {:error, any()}

  def run(query), do: impl().run(query)
  defp impl(), do: Canary.Query.Understander.FunctionCall
end

defmodule Canary.Query.Understander.FunctionCall do
  @behaviour Canary.Query.Understander

  def run(query) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model)
    embedding_model = Application.fetch_env!(:canary, :text_embedding_model)

    messages = [
      system_message(),
      %{role: "user", content: "User: #{query}"}
    ]

    case Canary.AI.chat(%{model: chat_model, messages: messages}) do
      {:ok, result} ->
        texts = result |> parse() |> Enum.map(& &1.phrase)
        docs = result |> parse() |> Enum.map(& &1.document)
        {:ok, embeddings} = Canary.AI.embedding(%{model: embedding_model, input: docs})

        quries =
          Enum.zip(texts, embeddings)
          |> Enum.map(fn {text, embedding} ->
            %Canary.Query{text: text, embedding: embedding}
          end)

        {:ok, quries}

      error ->
        error
    end
  end

  defp system_message() do
    %{
      role: "system",
      content: """
      You are a techincal support engineer. Based on the user's inquiry, write a structured query to find relevant resources from the internal knowledge base.

      Your output should strictly follow this XML-like format:

      <queries>
      <query>
      <phrase>
      PHRASE
      </phrase>
      <document>
      DOCUMENT
      </document>
      </query>
      </queries>

      Some notes:
      - There can be multiple "<query>" within the "<queries>". Most of the time, single query is enough. Max 3 queries are allowed.
      - "<phrase>" is one or two words that will be used to run keyword based search. Be specific as possible. Avoid single word if possible.
      - "<document>" is few plausible sentences that might exist in the knowledge base, and useful to answer the user's question.
        I know you don't have enough context to answer the question, but this guess is useful to narrow down the search space.
      """
    }
  end

  defp parse(text) do
    pattern = ~r/<query>\s*<phrase>(.*?)<\/phrase>\s*<document>(.*?)<\/document>\s*<\/query>/s

    pattern
    |> Regex.scan(text, capture: :all_but_first)
    |> Enum.map(fn [phrase, document] ->
      %{phrase: String.trim(phrase), document: String.trim(document)}
    end)
  end
end
