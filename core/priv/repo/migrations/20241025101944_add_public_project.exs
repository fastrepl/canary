defmodule Canary.Repo.Migrations.AddPublicProject do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :public, :boolean, default: false
    end
  end

  def down do
    alter table(:projects) do
      remove :public
    end
  end
end