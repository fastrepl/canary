defmodule Canary.Accounts.MembershipCalculation do
  use Ash.Resource.Calculation

  alias Canary.Accounts.Billing

  @impl true
  def init(opts), do: {:ok, opts}

  @impl true
  def load(_query, _opts, _context) do
    [
      {:account, [:super_user]},
      :stripe_subscription,
      :membership_override_tier,
      :membership_override_ends_at
    ]
  end

  @impl true
  def calculate(records, _opts, _args) do
    records
    |> Enum.map(fn %Billing{} = billing ->
      %{
        tier: tier(billing),
        grant: grant(billing),
        grant_end: grant_end(billing),
        trial: trial?(billing),
        trial_end: trial_end(billing),
        will_renew: will_renew?(billing),
        current_period_end: current_period_end(billing),
        status: status(billing)
      }
    end)
  end

  defp tier(%{account: %{super_user: true}}), do: :admin

  defp tier(%{membership_override_tier: tier, membership_override_ends_at: ends_at})
       when not is_nil(tier) and not is_nil(ends_at) do
    if DateTime.compare(DateTime.utc_now(), ends_at) == :gt do
      :free
    else
      tier
    end
  end

  defp tier(%{stripe_subscription: subscription}) when not is_nil(subscription) do
    starter_price_id = Application.fetch_env!(:canary, :stripe_starter_price_id)

    cond do
      is_nil(subscription) ->
        :free

      true ->
        found =
          subscription["items"]["data"] |> Enum.find(&(&1["price"]["id"] == starter_price_id))

        case found do
          nil -> :free
          %{"plan" => %{"active" => false}} -> :free
          %{"plan" => %{"active" => true}} -> :starter
        end
    end
  end

  defp tier(_), do: :free

  defp grant(%{account: %{super_user: true}}), do: true
  defp grant(%{membership_override_tier: tier}), do: not is_nil(tier)
  defp grant(_), do: false

  defp grant_end(%{membership_override_ends_at: ends_at}), do: ends_at
  defp grant_end(_), do: nil

  defp trial?(%{stripe_subscription: %{"trial_end" => v}}), do: not is_nil(v)
  defp trial?(_), do: false

  defp will_renew?(%{stripe_subscription: %{"cancel_at_period_end" => v}}), do: not v
  defp will_renew?(_), do: false

  defp current_period_end(%{stripe_subscription: %{"current_period_end" => v}}) do
    DateTime.from_unix!(v)
  end

  defp current_period_end(_), do: nil

  defp trial_end(%{
         stripe_subscription: %{
           "trial_end" => trial_end,
           "trial_settings" => %{"end_behavior" => %{"missing_payment_method" => _create_invoice}}
         }
       }) do
    case trial_end do
      nil -> nil
      t -> DateTime.from_unix!(t)
    end
  end

  defp trial_end(_), do: nil

  defp status(%{stripe_subscription: %{"status" => status}}), do: status
  defp status(_), do: nil
end
