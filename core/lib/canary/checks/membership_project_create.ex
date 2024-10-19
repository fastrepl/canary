defmodule Canary.Checks.Membership.ProjectCreate do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor has correct membership to create project"
  end

  def match?(
        %Canary.Accounts.Account{} = account,
        %Ash.Policy.Authorizer{resource: Canary.Accounts.Project},
        _opts
      ) do
    with {:ok, %{billing: billing, num_projects: num_projects}} <-
           Ash.load(account, [:billing, :num_projects]) do
      cond do
        is_nil(billing.stripe_subscription) and num_projects < 1 ->
          {:ok, true}

        not is_nil(billing.stripe_subscription) and num_projects < 3 ->
          {:ok, true}

        true ->
          {:ok, false}
      end
    else
      {:error, error} -> {:error, error}
      error -> error
    end
  end

  def match?(_, _, _), do: false
end
