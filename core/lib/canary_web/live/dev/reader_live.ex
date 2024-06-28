defmodule CanaryWeb.Dev.ReaderLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <form class="flex flex-row gap-2" phx-submit="submit">
        <input
          name="url"
          type="url"
          value={@url}
          autocomplete="off"
          placeholder="URL"
          class="input input-bordered w-full"
        />
        <button type="submit" class="btn btn-neutral">Enter</button>
      </form>

      <span class="font-semibold text-xs"><%= Enum.count(@chunks) %> chunks</span>
      <div class="flex flex-col gap-4 overflow-x-hidden hover:overflow-auto h-[calc(100vh-160px)]">
        <%= for chunk <- @chunks do %>
          <pre class="flex flex-row bg-gray-200"><%= chunk %></pre>
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
        |> Canary.Reader.html_to_md!()
        |> Canary.Native.chunk_markdown(1400)

      {:noreply, socket |> assign(url: params["url"], chunks: chunks)}
    else
      {:noreply, socket |> assign(url: "", chunks: [])}
    end
  end

  def handle_event("submit", %{"url" => url}, socket) do
    {:noreply, socket |> push_patch(to: "/dev/reader?url=#{url}")}
  end
end
