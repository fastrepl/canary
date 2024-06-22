defmodule CanaryWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  override AshAuthentication.Phoenix.Components.Banner do
    set(:text, "🐤 Canary")
    set(:text_class, "text-2xl font-bold text-black dark:text-white")
    set(:image_url, "")
    set(:dark_image_url, "")
  end
end
