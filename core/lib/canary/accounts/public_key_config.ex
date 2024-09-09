defmodule Canary.Accounts.PublicKeyConfig do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :allowed_host, :string, allow_nil?: true
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:allowed_host]

      change {
        Canary.Change.EnsureURLHost,
        input_argument: :allowed_host, output_attribute: :allowed_host
      }
    end

    update :update do
      primary? true
      accept [:allowed_host]

      change {
        Canary.Change.EnsureURLHost,
        input_argument: :allowed_host, output_attribute: :allowed_host
      }
    end
  end
end
