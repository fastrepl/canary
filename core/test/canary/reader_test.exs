defmodule Canary.Test.Reader do
  use ExUnit.Case, async: false

  describe "default" do
    test "simple" do
      html = """
      <!doctype html>
      <html>
      <body>
      <section id="content">
      <p class="headline">Floki</p>
      <span class="headline">Enables search using CSS selectors</span>
      <a href="https://github.com/philss/floki">Github page</a>
      <span data-model="user">philss</span>
      </section>
      <a href="https://hex.pm/packages/floki">Hex package</a>
      </body>
      </html>
      """

      {:ok, md} = Canary.Reader.Default.html_to_md(html)

      assert md ==
               """
               Floki
               Enables search using CSS selectors
               [Github page](https://github.com/philss/floki)
               philss
               [Hex package](https://hex.pm/packages/floki)
               """
               |> String.trim()
    end
  end
end
