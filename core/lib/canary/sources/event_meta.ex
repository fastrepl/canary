defmodule Canary.Sources.Event.Meta do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :level, :atom, constraints: [one_of: [:info, :warning, :error]], allow_nil?: false
    attribute :message, :string, allow_nil?: false
  end

  actions do
    defaults [:read, create: [:level, :message]]
  end

  code_interface do
    define :create, args: [:level, :message], action: :create
  end
end
