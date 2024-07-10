defmodule Canary.UserNotifier do
  import Swoosh.Email
  import Phoenix.Component

  alias Canary.Mailer

  @sender {"Canary", "yujonglee@getcanary.dev"}

  def deliver_invite_link(email, %{url: url}) do
    {html, text} = render_content(&invite_content/1, %{url: url})

    deliver(
      to: email,
      subject: "You are invited to join Canary!",
      html_body: html,
      text_body: text
    )
  end

  defp deliver(opts) do
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

  def invite_content(assigns) do
    ~H"""
    <.email_layout>
      <h1>Hey there!</h1>

      <p>Please use this link to sign in to Canary:</p>

      <a href={@url}><%= @url %></a>

      <p>If you didn't request this email, feel free to ignore this.</p>
    </.email_layout>
    """
  end

  defp email_layout(assigns) do
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

  defp render_content(content_fn, assigns) do
    template = content_fn.(assigns)
    html = heex_to_html(template)
    text = html_to_text(html)

    {html, text}
  end
end
