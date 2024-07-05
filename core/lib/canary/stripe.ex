defmodule Canary.Stripe do
  @stripe_api_base "https://api.stripe.com/v1"

  def new(options \\ []) when is_list(options) do
    Req.new(
      base_url: @stripe_api_base,
      auth: {:bearer, Application.fetch_env!(:canary, :stripe_api_key)}
    )
    |> Req.Request.append_request_steps(
      post: fn req ->
        with %{method: :get, body: <<_::binary>>} <- req do
          %{req | method: :post}
        end
      end
    )
    |> Req.merge(options)
  end

  def request(url, options \\ []), do: Req.request(new(url: parse_url(url)), options)

  def request!(url, options \\ []), do: Req.request!(new(url: parse_url(url)), options)

  defp parse_url("product_" <> _ = id), do: "/products/#{id}"
  defp parse_url("price_" <> _ = id), do: "/prices/#{id}"
  defp parse_url("sub_" <> _ = id), do: "/subscriptions/#{id}"
  defp parse_url("cus_" <> _ = id), do: "/customers/#{id}"
  defp parse_url("cs_" <> _ = id), do: "/checkout/sessions/#{id}"
  defp parse_url("inv_" <> _ = id), do: "/invoices/#{id}"
  defp parse_url("evt_" <> _ = id), do: "/events/#{id}"
  defp parse_url(url) when is_binary(url), do: url
end

defmodule Canary.Stripe.WebhookListener do
  use GenServer
  require Logger

  def start_link(options) do
    {stripe_cli, options} = Keyword.pop(options, :stripe_cli, System.find_executable("stripe"))
    {forward_to, options} = Keyword.pop!(options, :forward_to)
    options = Keyword.validate!(options, [:name, :timeout, :debug, :spawn_opt, :hibernate_after])
    GenServer.start_link(__MODULE__, %{stripe_cli: stripe_cli, forward_to: forward_to}, options)
  end

  @impl true
  def init(%{stripe_cli: nil}) do
    Logger.warning("Stripe CLI not found")
    :ignore
  end

  def init(%{stripe_cli: stripe_cli, forward_to: forward_to}) do
    # https://docs.stripe.com/cli/listen
    args = [
      "listen",
      "--skip-update",
      "--color",
      "--forward-to",
      forward_to
    ]

    port =
      Port.open(
        {:spawn_executable, stripe_cli},
        [
          :binary,
          :stderr_to_stdout,
          line: 2048,
          args: args
        ]
      )

    {:ok, port}
  end

  @impl true
  def handle_info({port, {:data, {:eol, line}}}, port) do
    Logger.info("stripe: #{line}")
    {:noreply, port}
  end
end
