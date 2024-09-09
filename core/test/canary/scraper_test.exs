defmodule Canary.Test.Scraper do
  use Canary.DataCase

  alias Canary.Scraper

  for {name, params} <- %{
        "getcanary.dev" => %{url: "https://getcanary.dev"}
      } do
    @tag params: params
    test name, %{params: params} do
      html = Req.get!(params[:url]).body
      assert Scraper.run!(html) |> length() > 0
    end
  end

  test "simple" do
    html = """
    <html>
      <body>
        <h1>Hello</h1>
        <p>World</p>
      </body>
    </html>
    """

    assert Scraper.run!(html) == [
             %Canary.Scraper.Item{
               content: "# Hello\nWorld",
               id: nil,
               level: 1,
               title: "Hello"
             }
           ]
  end
end
