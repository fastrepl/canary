defmodule CanaryWeb.NativeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <form phx-submit="process">
      <input type="text" name="input" value={@input} />
      <button type="submit">chunk</button>
    </form>

    <%= if @result do %>
      <div class="flex flex-row items-center">
        <h3>Result:</h3>
        <p><%= @result %></p>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, input: "", result: nil)}
  end

  def handle_event("process", %{"input" => input}, socket) do
    result = Jason.encode!(Canary.Native.chunk_text(input, 2))
    {:noreply, assign(socket, result: result)}
  end
end
