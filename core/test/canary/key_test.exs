defmodule Canary.Test.Key do
  use Canary.DataCase

  describe "public key config" do
    test "full url" do
      record =
        Canary.Accounts.PublicKeyConfig
        |> Ash.Changeset.for_create(:create, %{allowed_host: "https://example.com/"})
        |> Ash.create!()

      assert record.allowed_host == "example.com"
    end

    test "host" do
      record =
        Canary.Accounts.PublicKeyConfig
        |> Ash.Changeset.for_create(:create, %{allowed_host: "example.com"})
        |> Ash.create!()

      assert record.allowed_host == "example.com"
    end
  end
end
