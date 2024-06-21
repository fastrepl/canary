defmodule Canary.Repo.Migrations.CreateParadedbExtension do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"
    execute "CREATE EXTENSION IF NOT EXISTS pg_search"
  end

  def down do
    execute "DROP EXTENSION vector"
    execute "DROP EXTENSION pg_search"
  end
end
