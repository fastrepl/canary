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
    with {:ok, %{billing: _billing, num_projects: num_projects}} <-
           Ash.load(account, [:num_projects, billing: [:membership]]) do
      cond do
        num_projects < 1 ->
          {:ok, true}

        true ->
          {:ok, false}
      end
    end
  end

  def match?(_, _, _), do: false
end
