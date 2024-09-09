defmodule Canary.Type.KeyConfig do
  use Ash.Type.NewType,
    subtype_of: :union,
    constraints: [
      types: [
        public: [type: Canary.Accounts.PublicKeyConfig]
      ]
    ]
end
