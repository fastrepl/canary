defmodule CanaryWeb.Dev.ReaderLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
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
      <pre class="border rounded-md overflow-x-hidden hover:overflow-auto h-[calc(100vh-160px)]">
        <%= @content %>
      </pre>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    if params["url"] do
      content =
        params["url"]
        |> Req.get!()
        |> Map.get(:body)
        |> Canary.Native.html_to_md()

      {:noreply, socket |> assign(url: params["url"], content: content)}
    else
      {:noreply, socket |> assign(content: "")}
    end
  end

  def handle_event("submit", %{"url" => url}, socket) do
    {:noreply, socket |> push_patch(to: "/dev/reader?url=#{url}")}
  end
end
