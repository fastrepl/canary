defmodule Canary.Repo.Migrations.CreateSearchIndex do
  use Ecto.Migration

  def up do
    Canary.Sources.Chunk.Migration.up()
  end

  def down do
    Canary.Sources.Chunk.Migration.down()
  end
end
