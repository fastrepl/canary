defmodule Canary.Native do
  use Rustler, otp_app: :canary, crate: :canary_native

  @spec chunk_text(String.t(), pos_integer()) :: [String.t()]
  def chunk_text(_content, _max_tokens), do: error()

  @spec chunk_markdown(String.t(), pos_integer()) :: [String.t()]
  def chunk_markdown(_content, _max_tokens), do: error()

  defp error(), do: :erlang.nif_error(:nif_not_loaded)
end
