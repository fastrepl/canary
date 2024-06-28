defmodule Canary.Sessions do
  use Ash.Domain

  resources do
    resource Canary.Sessions.Session
    resource Canary.Sessions.Message
  end

  def find_or_create_session(account, {:discord, discord_id}) do
    case Canary.Sessions.Session.find_with_discord(account.id, discord_id) do
      {:ok, session} -> {:ok, session}
      {:error, _} -> Canary.Sessions.Session.create_with_discord(account, discord_id)
    end
  end

  def find_or_create_session(account, {:web, web_id}) do
    case Canary.Sessions.Session.find_with_web(account.id, web_id) do
      {:ok, session} -> {:ok, session}
      {:error, _} -> Canary.Sessions.Session.create_with_web(account, web_id)
    end
  end
end
