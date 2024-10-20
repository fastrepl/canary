defmodule Canary.Accounts.MembershipCalculation do
  use Ash.Resource.Calculation

  @impl true
  def init(opts) do
    if [
         :stripe_subscription_attribute
       ]
       |> Enum.any?(&is_nil(opts[&1])) do
      {:error, :invalid_opts}
    else
      {:ok, opts}
    end
  end

  @impl true
  def load(_query, opts, _context) do
    [
      opts[:stripe_subscription_attribute]
    ]
  end

  @impl true
  def calculate(records, opts, _args) do
    records
    |> Enum.map(fn record ->
      sub = record |> Map.get(opts[:stripe_subscription_attribute])

      %{
        tier: tier(sub),
        trial: trial?(sub),
        trial_end: trial_end(sub),
        will_renew: will_renew?(sub),
        current_period_end: current_period_end(sub),
        status: status(sub)
      }
    end)
  end

  defp tier(subscription) do
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
          _ -> :free
        end
    end
  end

  defp trial?(nil), do: false
  defp trial?(%{"trial_end" => v}), do: not is_nil(v)

  defp will_renew?(nil), do: false
  defp will_renew?(%{"cancel_at_period_end" => v}), do: not v

  defp current_period_end(nil), do: nil
  defp current_period_end(%{"current_period_end" => v}), do: DateTime.from_unix!(v)

  defp trial_end(nil), do: nil

  defp trial_end(%{
         "trial_end" => trial_end,
         "trial_settings" => %{"end_behavior" => %{"missing_payment_method" => _create_invoice}}
       }) do
    case trial_end do
      nil -> nil
      t -> DateTime.from_unix!(t)
    end
  end

  defp status(nil), do: nil
  defp status(%{"status" => status}), do: status
end
