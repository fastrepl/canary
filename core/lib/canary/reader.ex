defmodule Canary.Reader do
  @callback html_to_md(String.t()) :: {:ok, String.t()} | {:error, any()}

  def html_to_md(html), do: impl().html_to_md(html)

  def html_to_md!(arg) do
    {:ok, md} = html_to_md(arg)
    md
  end

  defp impl(), do: Canary.Reader.Default
end

defmodule Canary.Reader.Default do
  @behaviour Canary.Reader

  def html_to_md(html) do
    result =
      html
      |> Canary.Native.html_to_md()
      |> String.trim()

    {:ok, result}
  end
end
