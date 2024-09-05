defmodule Canary.Accounts.SubdomainConfig do
  use Ash.Resource, data_layer: :embedded

  attributes do
    attribute :name, :string, allow_nil?: false
    attribute :logo_url, :string, allow_nil?: true
  end

  validations do
    validate string_length(:name, min: 2, max: 255)
    validate string_length(:logo_url, min: 2, max: 255)
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:name, :logo_url]
    end

    update :update do
      primary? true
      accept [:name, :logo_url]
    end
  end
end
