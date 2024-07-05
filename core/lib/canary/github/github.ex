defmodule Canary.Github do
  use Ash.Domain

  resources do
    resource Canary.Github.App
    resource Canary.Github.Repo
  end
end
