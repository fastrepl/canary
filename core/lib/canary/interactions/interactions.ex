defmodule Canary.Interactions do
  use Ash.Domain

  resources do
    resource Canary.Interactions.Client
    resource Canary.Interactions.Session
    resource Canary.Interactions.Message
    resource Canary.Interactions.Feedback
  end

  alias Canary.Interactions.Session

  def find_or_create_session(account, {:discord, discord_id}) do
    case Session.find_with_discord(account.id, discord_id) do
      {:ok, session} -> {:ok, session}
      {:error, _} -> Session.create_with_discord(account, discord_id)
    end
  end

  def find_or_create_session(account, {:web, web_id}) do
    case Session.find_with_web(account.id, web_id) do
      {:ok, session} -> {:ok, session}
      {:error, _} -> Session.create_with_web(account, web_id)
    end
  end
end
