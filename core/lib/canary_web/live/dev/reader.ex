defmodule CanaryWeb.Dev.ReaderLive do
  use CanaryWeb, :live_view
  alias Canary.Scraper
  alias PrimerLive.Component, as: Primer

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <form class="flex flex-row gap-2 items-center" phx-submit="submit">
        <Primer.text_input
          name="url"
          type="url"
          value={@url}
          autocomplete="off"
          placeholder="URL"
          is_full_width
          is_large
        />
        <Primer.button type="submit">Enter</Primer.button>
      </form>
      <span class="font-semibold text-xs"><%= Enum.count(@chunks) %> chunks</span>
      <div class="flex flex-col gap-6 overflow-x-hidden h-[calc(100vh-200px)]">
        <%= for chunk <- @chunks do %>
          <div class="flex flex-col gap-1">
            <pre class="bg-gray-200"><%= Jason.encode!(%{id: chunk.id, level: chunk.level }) %></pre>
            <pre class="bg-gray-200"><%= chunk.content %></pre>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    if params["url"] do
      chunks =
        params["url"]
        |> Req.get!()
        |> Map.get(:body)
        |> Scraper.run()

      {:noreply, socket |> assign(url: params["url"], chunks: chunks)}
    else
      {:noreply, socket |> assign(url: "", chunks: [])}
    end
  end

  def handle_event("submit", %{"url" => url}, socket) do
    {:noreply, socket |> push_patch(to: "/dev/reader?url=#{url}")}
  end
end
