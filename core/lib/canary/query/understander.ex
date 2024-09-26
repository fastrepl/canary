defmodule Canary.Query.Understander do
  @callback run(list(any()), String.t()) :: {:ok, list(String.t())} | {:error, any()}

  alias Canary.Sources.Source
  alias Canary.Sources.SourceOverview

  def run(query, keywords), do: impl().run(query, keywords)
  defp impl(), do: Canary.Query.Understander.LLM

  def keywords(sources) when length(sources) == 0, do: []

  def keywords(sources) do
    sources =
      sources
      |> Enum.filter(fn
        %Source{overview: nil} -> false
        _ -> true
      end)

    limit =
      sources
      |> Enum.map(fn %Source{overview: overview} -> length(overview.keywords) end)
      |> Enum.min()

    sources
    |> Enum.flat_map(fn %Source{overview: %SourceOverview{} = overview} ->
      Enum.take(overview.keywords, limit)
    end)
    |> Enum.uniq()
  end
end

defmodule Canary.Query.Understander.LLM do
  @behaviour Canary.Query.Understander

  def run(query, keywords) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model)

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

    args = %{model: chat_model, messages: messages, temperature: 0}

    case Canary.AI.chat(args, timeout: 2_000) do
      {:ok, completion} ->
        parsed = parse(completion)

        Honeybadger.event("llm", %{
          task: "understander",
          query: query,
          messages: messages,
          completion: completion,
          parsed: parsed
        })

        {:ok, parsed}

      error ->
        error
    end
  end

  defp parse(completion) do
    case Regex.run(~r/<keywords>(.*?)<\/keywords>/s, completion) do
      [_, match] ->
        match
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      nil ->
        []
    end
  end
end
