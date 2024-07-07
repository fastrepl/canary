defmodule Canary.Accounts.Checks.IsMaster do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "if `MASTER_USER_EMAIL` is set, only allow master user to create account"
  end

  def match?(_, %Ash.Policy.Authorizer{subject: changeset}, _) do
    master_email = Application.get_env(:canary, :master_user_email, nil)
    current_email = Ash.Changeset.get_attribute(changeset, :email)

    cond do
      master_email == nil -> true
      master_email == to_string(current_email) -> true
      true -> false
    end
  end
end

defimpl AshPhoenix.FormData.Error, for: Ash.Error.Forbidden.Policy do
  alias Ash.Error.Forbidden.Policy
  alias Canary.Accounts.Checks.IsMaster

  def to_form_error(%Policy{facts: %{{IsMaster, [access_type: :filter]} => false}}) do
    {:email, "invalid email", nil}
  end
end
