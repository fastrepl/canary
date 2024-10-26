defmodule CanaryWeb.BillingLive.Stats do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mb-3 grid grid-cols-1 gap-5 lg:grid-cols-4">
      <dl class={[
        "col-span-4 grid grid-cols-1 divide-y divide-gray-200 overflow-hidden rounded-lg border bg-white shadow",
        "md:grid-cols-2 md:divide-x md:divide-y-0"
      ]}>
        <%= for metric <- @metrics do %>
          <%= if is_nil(metric) do %>
            <div class="px-4 py-5 sm:p-6">
              <dt class="text-base font-semibold">Current Plan</dt>
              <dd class="flex flex-col gap-2">
                <span class="text-6xl mt-2">
                  <%= case @current_account.billing.membership.tier do %>
                    <% :free -> %>
                      Free
                    <% :starter -> %>
                      Starter
                    <% :admin -> %>
                      Admin
                  <% end %>
                </span>
                <span :if={@current_account.billing.membership.grant_end} class="-mb-7">
                  Trial ends on <%= Calendar.strftime(
                    @current_account.billing.membership.grant_end,
                    "%B %d, %Y"
                  ) %>
                </span>
                <span :if={@current_account.billing.membership.trial_end} class="-mb-7">
                  Trial ends on <%= Calendar.strftime(
                    @current_account.billing.membership.trial_end,
                    "%B %d, %Y"
                  ) %>
                </span>
                <span :if={@plan_exceeded} class="-mb-7 text-red-600">
                  You have exceeded your limit. Please upgrade your plan.
                </span>
              </dd>
            </div>
          <% else %>
            <div class="px-4 py-5 sm:p-6">
              <dt class="text-base font-normal"><%= metric.title %></dt>
              <dd class="mt-1 flex items-baseline justify-between md:block lg:flex">
                <div class="flex flex-col items-baseline gap-3 text-2xl font-semibold">
                  <div>
                    <span class={[
                      "text-gray-800",
                      metric.current > metric.total && "text-red-600"
                    ]}>
                      <%= metric.current %>
                    </span>
                    <span class={[
                      "ml-1 text-sm text-gray-500",
                      metric.current > metric.total && "text-red-600"
                    ]}>
                      of <%= metric.total %>
                    </span>
                  </div>
                  <div class="h-2.5 rounded-full bg-gray-200" style="width: 300px;">
                    <div
                      class="h-2.5 rounded-full bg-gray-500"
                      style={"width: #{300 * ratio(metric.current, metric.total)}px"}
                    >
                    </div>
                  </div>
                </div>
              </dd>
            </div>
          <% end %>
        <% end %>
      </dl>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_account = assigns.current_account |> Ash.load!([:users, :projects])

    num_sources =
      current_account.projects
      |> Ash.load!(:num_sources)
      |> Enum.map(& &1.num_sources)
      |> Enum.sum()

    {:ok, usage} =
      Canary.Analytics.query(:last_month_usage, %{account_id: assigns.current_account.id})

    %{"sum" => search_usage} =
      usage |> Enum.find(%{"type" => "search", "sum" => 0}, &(&1["type"] == "search"))

    %{"sum" => ask_usage} =
      usage |> Enum.find(%{"type" => "ask", "sum" => 0}, &(&1["type"] == "ask"))

    metrics = [
      nil,
      %{
        title: "Total Projects",
        current: length(current_account.projects),
        total: Canary.Membership.max_projects(current_account)
      },
      %{
        title: "Total Users",
        current: length(current_account.users),
        total: Canary.Membership.max_members(current_account)
      },
      %{
        title: "Total Sources",
        current: num_sources,
        total: Canary.Membership.max_sources(current_account)
      },
      %{
        title: "Searches in the last 30 days",
        current: search_usage,
        total: Canary.Membership.max_searches(current_account)
      },
      %{
        title: "'Ask AI' in the last 30 days",
        current: ask_usage,
        total: Canary.Membership.max_asks(current_account)
      }
    ]

    plan_exceeded =
      metrics
      |> Enum.reject(&is_nil/1)
      |> Enum.any?(&(&1.current > &1.total))

    socket =
      socket
      |> assign(assigns)
      |> assign(:current_account, current_account)
      |> assign(:metrics, metrics)
      |> assign(:plan_exceeded, plan_exceeded)

    {:ok, socket}
  end

  defp ratio(_, 0), do: 0
  defp ratio(current, total), do: min(1, Float.round(current / total, 2))
end
