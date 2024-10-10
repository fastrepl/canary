defmodule CanaryWeb.Plug.LoadAccountFromUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil -> conn |> assign(:current_account, nil)
      user -> conn |> assign(:current_account, current_account(user))
    end
  end

  defp current_account(user) do
    accounts = user |> Ash.load!(:accounts) |> Map.get(:accounts)
    if length(accounts) > 0, do: Enum.at(accounts, 0), else: nil
  end
end
