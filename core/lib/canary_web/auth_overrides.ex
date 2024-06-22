defmodule CanaryWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  override AshAuthentication.Phoenix.Components.Banner do
    set(:image_url, "")
    set(:dark_image_url, "")
  end
end
