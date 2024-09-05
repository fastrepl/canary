defmodule CanaryWeb.SourceLive.Crawler do
  use CanaryWeb, :live_component

  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row gap-8">
      <div class="basis-2/5">
        <.form
          :let={f}
          phx-submit="submit"
          phx-target={@myself}
          for={@form}
          class="flex flex-col justify-between gap-4 h-[calc(100vh-120px)]"
        >
          <div class="flex flex-col gap-4">
            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Name</span>
              </div>
              <input type="text" disabled value="Canary" class="input input-bordered w-full" />
            </label>

            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Base URL</span>
              </div>
              <input
                type="text"
                disabled
                name={f[:web_url_base].name}
                value={f[:web_url_base].value}
                class="input input-bordered w-full"
              />
            </label>

            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Include URL patterns</span>
                <span class="label-text-alt">(Comma separated)</span>
              </div>
              <input
                type="text"
                autocomplete="off"
                spellcheck="false"
                name={f[:web_url_include_patterns].name}
                value={Enum.join(f[:web_url_include_patterns].value, ",")}
                class="input input-bordered w-full"
              />
            </label>

            <label class="form-control w-full">
              <div class="label">
                <span class="label-text">Exclude URL patterns</span>
                <span class="label-text-alt">(Comma separated)</span>
              </div>
              <input
                type="text"
                autocomplete="off"
                spellcheck="false"
                name={f[:web_url_exclude_patterns].name}
                value={Enum.join(f[:web_url_exclude_patterns].value, ",")}
                class="input input-bordered w-full"
              />
            </label>
          </div>

          <div class="flex flex-col gap-4 mt-auto">
            <button type="submit" name="dry_run" class="btn btn-md w-full">
              <%= if @crawler_task_result.loading do %>
                <span class="loading loading-spinner w-4 h-4"></span>
              <% else %>
                Test Crawler
              <% end %>
            </button>
            <button type="submit" name="save" class="btn btn-neutral btn-md w-full">
              Save
            </button>
          </div>
        </.form>
      </div>

      <div class="basis-3/5 border rounded-md p-4">
        <div class="overflow-y-auto h-[calc(100vh-150px)]">
          <%= if @crawler_task_result.loading do %>
            <span class="loading loading-spinner w-4 h-4"></span>
          <% else %>
            <table class="table table-xs table-pin-rows">
              <thead>
                <tr>
                  <th></th>
                  <th>URL</th>
                </tr>
              </thead>
              <tbody>
                <%= for {item, index} <- Enum.with_index(@crawler_task_result.result) do %>
                  <tr class="hover cursor-pointer" onclick={"window.open('#{item.url}')"}>
                    <th><%= index + 1 %></th>
                    <td><%= item.url %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    form =
      socket.assigns.source
      |> AshPhoenix.Form.for_update(:update)
      |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:crawler_task_result, AsyncResult.ok([]))

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"dry_run" => _, "form" => form}, socket) do
    socket =
      socket
      |> start_crawler_task(
        include_patterns: parse_patterns(form["web_url_include_patterns"]),
        exclude_patterns: parse_patterns(form["web_url_exclude_patterns"])
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"save" => _, "form" => form}, socket) do
    params = %{
      web_url_include_patterns: parse_patterns(form["web_url_include_patterns"]),
      web_url_exclude_patterns: parse_patterns(form["web_url_exclude_patterns"])
    }

    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
        {:ok, source} ->
          socket
          |> assign(:mode, "Status")
          |> assign(source: source)
          |> assign(:form, AshPhoenix.Form.for_update(source, :update) |> to_form())

        {:error, form} ->
          socket |> assign(:form, form)
      end

    {:noreply, socket}
  end

  defp start_crawler_task(socket, opts) do
    base_url = socket.assigns.source.web_url_base

    socket
    |> assign(:crawler_task_result, AsyncResult.loading())
    |> start_async(:crawler_task, fn ->
      {:ok, map} = Canary.Crawler.run(base_url, opts)
      list = map |> Map.keys() |> Enum.map(&%{url: &1})
      {:ok, list}
    end)
  end

  @impl true
  def handle_async(:crawler_task, {:ok, result}, socket) do
    socket =
      case result do
        {:ok, value} -> socket |> assign(:crawler_task_result, AsyncResult.ok(value))
        {:error, error} -> socket |> assign(:crawler_task_result, AsyncResult.failed([], error))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_async(:crawler_task, {:exit, reason}, socket) do
    socket =
      socket
      |> assign(:crawler_task_result, AsyncResult.failed([], reason))

    {:noreply, socket}
  end

  defp parse_patterns(patterns) when is_binary(patterns) do
    patterns
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
