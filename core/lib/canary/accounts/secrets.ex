defmodule Canary.Accounts.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Canary.Accounts.User, _) do
    case Application.fetch_env(:canary, CanaryWeb.Endpoint) do
      {:ok, endpoint_config} -> Keyword.fetch(endpoint_config, :secret_key_base)
      :error -> :error
    end
  end

  def secret_for([:authentication, :strategies, :github, :client_id], Canary.Accounts.User, _) do
    get_config(:client_id)
  end

  def secret_for([:authentication, :strategies, :github, :redirect_uri], Canary.Accounts.User, _) do
    get_config(:redirect_uri)
  end

  def secret_for([:authentication, :strategies, :github, :client_secret], Canary.Accounts.User, _) do
    get_config(:client_secret)
  end

  defp get_config(key) do
    :canary
    |> Application.get_env(:github, [])
    |> Keyword.fetch(key)
  end
end
