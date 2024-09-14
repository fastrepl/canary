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

    overviews =
      sources
      |> Enum.map(fn %Source{name: name, overview: %SourceOverview{} = overview} ->
        %{name: name, titles: overview.titles, keywords: overview.keywords}
      end)

    messages = [
      %{
        role: "system",
        content: Canary.Prompt.format("understander_system", %{})
      },
      %{
        role: "user",
        content: Canary.Prompt.format("understander_user", %{query: query, sources: overviews})
      }
    ]

    case Canary.AI.chat(%{model: chat_model, messages: messages}, timeout: 2_000) do
      {:ok, completion} -> {:ok, parse(completion)}
      error -> error
    end
  end

  defp parse(completion) do
    case Regex.run(~r/<query>(.*?)<\/query>/s, completion) do
      [_, match] ->
        match
        |> String.split(",")
        |> Enum.map(&String.trim/1)

      nil ->
        []
    end
  end
end
