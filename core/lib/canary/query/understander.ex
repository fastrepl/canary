defmodule Canary.Query.Understander do
  @callback run(list(any()), String.t()) :: {:ok, list(String.t())} | {:error, any()}

  def run(sources, query), do: impl().run(sources, query)
  defp impl(), do: Canary.Query.Understander.LLM
end

defmodule Canary.Query.Understander.LLM do
  @behaviour Canary.Query.Understander

  alias Canary.Sources.Source
  alias Canary.Sources.SourceOverview

  def run(sources, query) do
    chat_model = Application.fetch_env!(:canary, :chat_completion_model)

    keywords =
      sources
      |> Enum.flat_map(fn
        %Source{overview: nil} -> []
        %Source{overview: %SourceOverview{} = overview} -> overview.keywords
      end)
      |> Enum.uniq()

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

    args = %{model: chat_model, messages: messages}

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
