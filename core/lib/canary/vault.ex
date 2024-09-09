defmodule Canary.Vault do
  use Cloak.Vault, otp_app: :canary

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1",
          key: Base.decode64!("Mwq3tdb4L7sPE+6YqDXriPfWxmz0qA9ZXJkjt2oOEFI="),
          iv_length: 12
        }
      )

    {:ok, config}
  end
end
