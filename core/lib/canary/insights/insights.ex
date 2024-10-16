defmodule Canary.Insights do
  use Ash.Domain

  resources do
    resource Canary.Insights.Config
  end
end
