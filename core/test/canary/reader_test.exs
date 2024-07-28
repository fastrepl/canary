defmodule Canary.Test.Reader do
  use ExUnit.Case, async: true

  test "title_from_html" do
    html = """
    <!doctype html>
    <html>
      <head>
        <title>Canary</title>
      </head>
      <body>
      </body>
    </html>
    """

    assert Canary.Reader.title_from_html(html) == "Canary"
  end

  test "markdown_from_html" do
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

    md = "Floki\n\nEnables search using CSS selectorsphilss"
    assert Canary.Reader.markdown_from_html(html) == md
  end

  test "chunks_from_html" do
    html = """
    <!doctype html>
    <html>
      <body>
        <h1>title</h1>
        123
        <h2 id="part1">456</h2>
        <p>456</p>
        <h2 id="part2">789</h2>
        <p>789</p>
      </body>
    </html>
    """

    assert Canary.Reader.markdown_from_html(html) ==
             "# title\n\n123\n\n## 456\n\n456\n\n## 789\n\n789"

    assert Canary.Reader.chunks_from_html(html) == [
             %{anchor: nil, content: "# title\n\n123\n\n## 456\n\n456"},
             %{anchor: "part1", content: "## 456\n\n456"},
             %{anchor: "part2", content: "## 789\n\n789"}
           ]
  end
end
