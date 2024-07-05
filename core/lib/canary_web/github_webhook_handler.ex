defmodule CanaryWeb.GithubWebhookHandler do
  # https://docs.github.com/en/webhooks/webhook-events-and-payloads#installation
  def handle_event("installation", payload) do
    %{
      "action" => action,
      "installation" => %{"id" => installation_id},
      "repositories" => repos
    } = payload

    case action do
      "created" ->
        repos
        |> Enum.map(& &1["full_name"])
        |> then(&Canary.Github.App.create(installation_id, &1))

      "deleted" ->
        installation_id
        |> Canary.Github.App.delete()

      _ ->
        :ok
    end
  end

  # https://docs.github.com/en/webhooks/webhook-events-and-payloads#installation_repositories
  def handle_event("installation_repositories", payload) do
    %{
      "action" => action,
      "installation" => %{"id" => installation_id},
      "repositories_added" => repositories_added,
      "repositories_removed" => repositories_removed
    } = payload

    app = Canary.Github.App.find(installation_id)

    case app do
      {:ok, app} ->
        case action do
          "added" ->
            repositories_added
            |> Enum.map(&%{app: app, full_name: &1["full_name"]})
            |> Ash.bulk_create(Canary.Github.Repo, :create)

          "removed" ->
            repositories_removed
            |> Enum.map(& &1["full_name"])
            |> then(&Canary.Github.Repo.delete(app, &1))

          _ ->
            :ok
        end

      {:error, _} ->
        :error
    end
  end

  # https://docs.github.com/en/webhooks/webhook-events-and-payloads#push
  def handle_event("push", payload) do
    %{
      "installation" => %{"id" => _installation_id},
      "commits" => commits
    } = payload

    _added = Enum.map(commits, & &1["added"])
    _removed = Enum.map(commits, & &1["removed"])
    _modified = Enum.map(commits, & &1["modified"])

    :ok
  end

  def handle_event(event, _payload) do
    {:error, %{type: :unhandled, event: event}}
  end
end
