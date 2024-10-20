defmodule Canary.Repo.Migrations.AddIndexIdToDoc do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:documents) do
      add :index_id, :uuid, null: true
    end
  end

  def down do
    alter table(:documents) do
      remove :index_id
    end
  end
end
