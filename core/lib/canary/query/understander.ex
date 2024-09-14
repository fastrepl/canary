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

  def run(query, keywords) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model_understanding)

    messages = [
      %{
        role: "system",
        content: Canary.Prompt.format("understander_system", %{})
      },
      %{
        role: "user",
        content: Canary.Prompt.format("understander_user", %{query: query, keywords: keywords})
      }
    ]

    case Canary.AI.chat(%{model: chat_model, messages: messages}, timeout: 2_000) do
      {:ok, analysis} -> {:ok, parse(query, analysis)}
      error -> error
    end
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
