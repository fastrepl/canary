defmodule Canary.Workers.Email do
  use Oban.Worker, queue: :fetcher, max_attempts: 3

  @sender {"Canary", "yujonglee@getcanary.dev"}

  @impl true
  def perform(%Oban.Job{args: args}) do
    %{"to" => to, "subject" => subject, "html_body" => html_body, "text_body" => text_body} = args

    Canary.Mailer.deliver(
      Swoosh.Email.new(
        from: @sender,
        to: to,
        subject: subject,
        html_body: html_body,
        text_body: text_body
      )
    )
  end
end
