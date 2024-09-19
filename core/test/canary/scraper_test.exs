defmodule Canary.Test.Scraper do
  use ExUnit.Case, async: true

  alias Canary.Scraper

  describe "it works without crashing" do
    for {name, params} <- %{
          "getcanary.dev" => %{url: "https://getcanary.dev"},
          "nextjs.org" => %{url: "https://nextjs.org/docs"},
          "sentry.io" => %{url: "https://docs.sentry.io/product/sentry-basics"},
          "hono.dev" => %{url: "https://hono.dev"}
        } do
      @tag params: params
      test name, %{params: params} do
        html = Req.get!(params[:url]).body
        assert Scraper.run(html) |> length() > 1
      end
    end
  end

  test "canary-1" do
    html = File.read!("test/fixtures/canary-1.html")
    items = Scraper.run(html)
    assert length(items) == 3

    assert Enum.at(items, 0).level == 1
    assert Enum.at(items, 0).id == "not-everyone-needs-a-hosted-service"
    assert Enum.at(items, 0).title == "Not everyone needs a hosted service."
  end

  test "hono-1" do
    html = File.read!("test/fixtures/hono-1.html")
    items = Scraper.run(html)
    assert length(items) == 13

    assert Enum.at(items, 0).level == 1
    assert Enum.at(items, 0).id == "bearer-auth-middleware"
    assert Enum.at(items, 0).title == "Bearer Auth Middleware"
  end

  test "litellm-1" do
    html = File.read!("test/fixtures/litellm-1.html")

    items = Scraper.run(html)
    assert length(items) == 17

    assert Enum.at(items, 0).level == 1
    assert Enum.at(items, 0).id == nil
    assert Enum.at(items, 0).title == "LiteLLM - Getting Started"
  end
end
