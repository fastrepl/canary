defmodule Canary.UserNotifier do
  import Swoosh.Email
  import Phoenix.Component

  alias Canary.Mailer

  @sender {"Canary", "yujonglee@getcanary.dev"}

  def deliver(opts) do
    email =
      new(
        from: @sender,
        to: opts[:to],
        subject: opts[:subject],
        html_body: opts[:html_body],
        text_body: opts[:text_body]
      )

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def default_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
          body {
            font-family: system-ui, sans-serif;
            margin: 3em auto;
            overflow-wrap: break-word;
            word-break: break-all;
            max-width: 1024px;
            padding: 0 1em;
          }
        </style>
      </head>
      <body>
        <%= render_slot(@inner_block) %>
      </body>
    </html>
    """
  end

  def render_content(content_fn, assigns) do
    template = content_fn.(assigns)
    html = heex_to_html(template)
    text = html_to_text(html)

    {html, text}
  end

  defp heex_to_html(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp html_to_text(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.text(sep: "\n\n")
  end
end

defmodule Canary.UserNotifier.ResetPassword do
  import Phoenix.Component
  import Canary.UserNotifier, only: [deliver: 1, render_content: 2, default_layout: 1]

  use AshAuthentication.Sender
  use CanaryWeb, :verified_routes

  @impl AshAuthentication.Sender
  def send(user, token, _) do
    assigns = %{user: user, url: url(~p"/password-reset/#{token}")}
    {html, text} = render_content(&tpl/1, assigns)

    deliver(
      to: to_string(user.email),
      subject: "Canary: Reset your password",
      html_body: html,
      text_body: text
    )

    :ok
  end

  defp tpl(assigns) do
    ~H"""
    <.default_layout>
      <p>
        Hi <%= @user.email %>,
      </p>

      <p>
        <a href={@url}>Click here</a> to reset your password.
      </p>

      <p>
        If you didn't request this change, please ignore this.
      </p>
    </.default_layout>
    """
  end
end
