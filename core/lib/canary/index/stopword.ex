defmodule Canary.Index.Stopword do
  def id(), do: "default_stopwords"

  def ensure() do
    result =
      Canary.Index.Client.upsert_stopwords_set(id(), %{
        locale: "en",
        stopwords: Canary.Native.stopwords()
      })

    case result do
      {:ok, _} -> :ok
      error -> error
    end
  end
end
