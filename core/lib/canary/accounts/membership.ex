defmodule Canary.Accounts.Membership do
  use Ash.Type.Enum, values: [:free, :starter, :admin]
end
