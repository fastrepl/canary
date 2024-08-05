defmodule Canary.Native do
  use Rustler, otp_app: :canary, crate: :canary_native

  @spec chunk_text(String.t(), pos_integer()) :: [String.t()]
  def chunk_text(_content, _max_tokens), do: error()

  @spec chunk_markdown(String.t(), pos_integer()) :: [String.t()]
  def chunk_markdown(_content, _max_tokens), do: error()

  @spec html_to_md(String.t()) :: String.t()
  def html_to_md(_html), do: error()

  @spec html_to_md_with_marker(String.t()) :: String.t()
  def html_to_md_with_marker(_html), do: error()

  @spec clone_depth(String.t(), String.t(), pos_integer()) :: boolean()
  def clone_depth(_repo_url, _dest_path, _depth), do: error()

  @spec extract_keywords(String.t(), non_neg_integer()) :: list(String.t())
  def extract_keywords(_content, _n), do: error()

  @spec stopwords() :: list(String.t())
  def stopwords(), do: error()

  defp error(), do: :erlang.nif_error(:nif_not_loaded)
end
