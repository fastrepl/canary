defmodule Canary.Overview do
  def titles(%Canary.Sources.Source{} = source) do
    documents =
      source
      |> Ash.load!([:documents])
      |> Map.get(:documents)

    documents
    |> Enum.flat_map(fn %Canary.Sources.Document{chunks: chunks} ->
      Enum.map(chunks, fn %Ash.Union{value: value} -> value.title end)
    end)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  def keywords(%Canary.Sources.Source{} = source) do
    documents =
      source
      |> Ash.load!([:documents])
      |> Map.get(:documents)

    documents
    |> Enum.flat_map(fn %Canary.Sources.Document{chunks: chunks} ->
      Enum.map(chunks, fn %Ash.Union{value: value} -> value.content end)
    end)
    |> Enum.join("\n")
    |> then(&Canary.Native.extract_keywords(&1, length(documents) * 20))
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
