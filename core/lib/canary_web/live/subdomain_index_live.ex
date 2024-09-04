defmodule CanaryWeb.SubdomainIndexLive do
  use CanaryWeb, :live_view

  use Phoenix.VerifiedRoutes,
    endpoint: CanaryWeb.Endpoint,
    router: CanaryWeb.SubdomainRouter,
    statics: CanaryWeb.static_paths()

  def render(assigns) do
    ~H"""
    <ul
      id="posts"
      phx-update="stream"
      phx-viewport-top={@page > 1 && "prev-page"}
      phx-viewport-bottom={!@end_of_timeline? && "next-page"}
      phx-page-loading
      class={[
        if(@end_of_timeline?, do: "pb-10", else: "pb-[calc(200vh)]"),
        if(@page == 1, do: "pt-10", else: "pt-[calc(200vh)]")
      ]}
    >
      <li :for={{id, post} <- @streams.posts} id={id}>
        <.link navigate={~p"/post/#{post.id}"}>
          <div class="border p-4 mb-4 rounded-lg shadow">
            <h2 class="text-xl font-bold"><%= post.title %></h2>
            <p class="text-gray-600"><%= post.excerpt %></p>
          </div>
        </.link>
      </li>
    </ul>
    <div :if={@end_of_timeline?} class="mt-5 text-[50px] text-center">
      🎉 You made it to the beginning of time 🎉
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 20, end_of_timeline?: false)
     |> paginate_posts(1)}
  end

  def handle_event("next-page", _, socket) do
    {:noreply, paginate_posts(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_posts(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_posts(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  defp paginate_posts(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns
    posts = mock_list_posts(offset: (new_page - 1) * per_page, limit: per_page)

    {posts, at, limit} =
      if new_page >= cur_page do
        {posts, -1, per_page * 3 * -1}
      else
        {Enum.reverse(posts), 0, per_page * 3}
      end

    case posts do
      [] ->
        assign(socket, end_of_timeline?: at == -1)

      [_ | _] = posts ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:posts, posts, at: at, limit: limit)
    end
  end

  defp mock_list_posts(offset: offset, limit: limit) do
    Enum.map((offset + 1)..(offset + limit), fn i ->
      %{
        id: "post-#{i}",
        title: "Post #{i}",
        excerpt: "This is a mock excerpt for post #{i}."
      }
    end)
  end
end
