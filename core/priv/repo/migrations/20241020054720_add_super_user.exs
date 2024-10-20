defmodule Canary.Repo.Migrations.AddSuperUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:accounts) do
      add :super_user, :boolean, default: false
    end
  end

  def down do
    alter table(:accounts) do
      remove :super_user
    end
  end
end
