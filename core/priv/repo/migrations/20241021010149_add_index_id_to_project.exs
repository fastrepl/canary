defmodule Canary.Repo.Migrations.AddIndexIdToProject do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :index_id, :text
    end
  end

  def down do
    alter table(:projects) do
      remove :index_id
    end
  end
end