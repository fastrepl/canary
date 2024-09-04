defmodule CanaryWeb.SubdomainPostLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-md font-bold"><%= @post.title %></h1>
      <p><%= @post.excerpt %></p>
      <.link navigate={~p"/"}>Back to index</.link>
    </div>
    """
  end

  def mount(%{"id" => _id}, _session, socket) do
    {:ok, socket |> assign(:post, %{title: "Post", excerpt: "This is a mock excerpt."})}
  end
end
