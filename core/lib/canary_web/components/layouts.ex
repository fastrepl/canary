defmodule CanaryWeb.Layouts do
  use CanaryWeb, :html

  embed_templates "layouts/*"

  attr :active_tab, :any, default: nil

  def side_menu(assigns) do
    ~H"""
    <span><%= @active_tab %></span>
    """
  end
end
