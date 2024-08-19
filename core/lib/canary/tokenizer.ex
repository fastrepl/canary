defmodule Canary.Tokenizer do
  @tokenizer_ids %{
    llama: "NousResearch/Llama-2-7b-hf"
  }

  def load(:llama), do: load_tokenizer(@tokenizer_ids.llama)

  defp load_tokenizer(id) do
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, id})
    tokenizer
  end

  def truncate_text(_tokenizer, _text, max_tokens) when max_tokens <= 0, do: ""

  def truncate_text(tokenizer, text, max_tokens) do
    total_ids = tokenizer |> Bumblebee.apply_tokenizer(text) |> Map.get("input_ids")
    total_ids_size = Nx.shape(total_ids) |> elem(1)
    truncated_ids = total_ids |> Nx.slice([0, 0], [1, min(total_ids_size, max_tokens)])

    tokenizer
    |> Bumblebee.Tokenizer.decode(truncated_ids)
    |> get_in([Access.at(0)])
  end

  def count_tokens(tokenizer, text) do
    tokenizer
    |> Bumblebee.apply_tokenizer(text)
    |> Map.get("token_type_ids")
    |> Nx.shape()
    |> elem(1)
  end
end
