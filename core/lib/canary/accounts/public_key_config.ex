defmodule Canary.Accounts.PublicKeyConfig do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :allowed_hosts, {:array, :string},
      allow_nil?: false,
      constraints: [nil_items?: false, min_length: 1, max_length: 99]
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:allowed_hosts]

      change {
        Canary.Change.EnsureURLHost,
        input_argument: :allowed_hosts, output_attribute: :allowed_hosts
      }
    end

    update :update do
      primary? true
      accept [:allowed_hosts]

      change {
        Canary.Change.EnsureURLHost,
        input_argument: :allowed_hosts, output_attribute: :allowed_hosts
      }
    end
  end
end
