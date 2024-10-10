defmodule CanaryWeb.Plug.LoadProjectFromAccount do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_account] do
      nil -> conn |> assign(:current_project, nil)
      account -> conn |> assign(:current_project, current_project(account))
    end
  end

  defp current_project(account) do
    projects = account |> Ash.load!(:projects) |> Map.get(:projects)
    if length(projects) > 0, do: Enum.at(projects, 0), else: nil
  end
end
