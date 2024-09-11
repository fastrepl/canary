defmodule Canary.Index.Stopword do
  def id(), do: "default_stopwords"

  def ensure() do
    Canary.Index.Client.upsert_stopwords_set(id(), %{
      locale: "en",
      stopwords: Canary.Native.stopwords()
    })
  end
end
