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
end
