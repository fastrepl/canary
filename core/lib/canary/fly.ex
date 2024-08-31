defmodule Canary.Fly do
  defp app_name(), do: Application.fetch_env!(:canary, :fly_app_name)
  defp api_key(), do: Application.fetch_env!(:canary, :fly_api_key)

  defp client() do
    Canary.graphql_client(
      url: "https://api.fly.io/graphql",
      auth: {:bearer, api_key()}
    )
  end

  def list_certificates() do
    client()
    |> Req.post!(
      graphql:
        {"""
          query($appName: String!) {
            app(name: $appName) {
              certificates {
                nodes {
                  createdAt
                  hostname
                  clientStatus
                }
              }
            }
          }
         """, %{appName: app_name()}}
    )
    |> get_in([Access.key(:body), "data", "app", "certificates", "nodes"])
  end

  def create_certificate(hostname) do
    client()
    |> Req.post!(
      graphql:
        {"""
          mutation($appId: ID!, $hostname: String!) {
            addCertificate(appId: $appId, hostname: $hostname) {
              certificate {
                id
                hostname
              }
            }
          }
         """, %{appId: app_name(), hostname: hostname}}
    )
    |> get_in([Access.key(:body), "data", "addCertificate", "certificate"])
  end

  def delete_certificate(hostname) do
    client()
    |> Req.post!(
      graphql:
        {"""
          mutation($appId: ID!, $hostname: String!) {
            deleteCertificate(appId: $appId, hostname: $hostname) {
              app {
                name
              }
              certificate {
                id
                hostname
              }
            }
          }
         """, %{appId: app_name(), hostname: hostname}}
    )
    |> get_in([Access.key(:body), "data", "deleteCertificate"])
  end
end
