defmodule Canary.Repo.Migrations.AddBm25Index do
  use Ecto.Migration

  def up do
    Canary.Sources.Document.Migration.up()
  end

  def down do
    Canary.Sources.Document.Migration.down()
  end
end
