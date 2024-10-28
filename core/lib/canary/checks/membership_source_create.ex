defmodule Canary.Checks.Membership.SourceCreate do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor has correct membership to create source"
  end

  def match?(
        %Canary.Accounts.Account{} = account,
        %Ash.Policy.Authorizer{
          resource: Canary.Sources.Source,
          changeset: %Ash.Changeset{relationships: %{project: [{[%{id: id}], _}]}}
        },
        _opts
      ) do
    with {:ok, %{billing: billing}} <- Ash.load(account, billing: [:membership]),
         {:ok, %{num_sources: num_sources}} <-
           Ash.get(Canary.Accounts.Project, id, load: [:num_sources]) do
      cond do
        num_sources < Canary.Membership.max_sources(billing.membership.tier) ->
          {:ok, true}

        true ->
          {:ok, false}
      end
    end
  end

  def match?(_, _, _), do: false
end
