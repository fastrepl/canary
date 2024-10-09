defmodule Canary.Notifiers.Discord do
  use Ash.Notifier

  def notify(%Ash.Notifier.Notification{
        action: %{name: name},
        resource: resource,
        data: %{id: id}
      }) do
    webhook_url = Application.get_env(:canary, :discord_webhook_url)

    if webhook_url do
      data = %{
        id: id,
        resource: resource,
        action: name
      }

      content =
        data
        |> with_env()
        |> Jason.encode!()

      Req.post(url: webhook_url, json: %{content: content})
    end

    :ok
  end

  defp with_env(map), do: map |> Map.merge(%{env: Application.get_env(:canary, :env)})
end
