defmodule Canary.Repo.Migrations.AddIndex do
  use Ecto.Migration

  def up do
    Canary.Sources.Chunk.Migration.up()
  end

  def down do
    Canary.Sources.Chunk.Migration.down()
  end
end
