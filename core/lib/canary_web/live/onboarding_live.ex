defmodule CanaryWeb.OnboardingLive do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto mt-[100px]">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold">
          🐤 Canary Onboarding
        </h1>
        <p>Please follow the steps below.</p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
