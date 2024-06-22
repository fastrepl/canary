defmodule Canary.Sessions do
  def registry() do
    Application.fetch_env!(:canary, :session_registry)
  end

  def find_or_start_session(id) do
    case find_session(id) do
      nil -> start_session(id)
      pid -> {:ok, pid}
    end
  end

  defp find_session(id) do
    case Registry.lookup(registry(), id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  defp start_session(id) do
    Canary.Sessions.Session.start_link(%{id: id})
  end
end
