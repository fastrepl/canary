defmodule Canary.Checks.Membership.SourceCreate do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor has correct membership to create source"
  end

  def match?(
        %Canary.Accounts.Account{} = account,
        %Ash.Policy.Authorizer{
          resource: Canary.Sources.Source,
          changeset: %Ash.Changeset{relationships: %{project: [{[%{id: id}], _}]}} = changeset
        },
        _opts
      ) do
    with {:ok, %{billing: billing}} <- Ash.load(account, :billing),
         {:ok, %{num_sources: num_sources}} <-
           Ash.get(Canary.Accounts.Project, id, load: [:num_sources]) do
      %Ash.Union{type: source_type} = Ash.Changeset.get_attribute(changeset, :config)

      cond do
        is_nil(billing.stripe_subscription) and source_type == :webpage and num_sources < 1 ->
          {:ok, true}

        not is_nil(billing.stripe_subscription) and num_sources < 4 ->
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
