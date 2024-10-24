defmodule Canary.Repo.Migrations.MoveSelectionToUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :selected_account_id, :uuid
      add :selected_project_id, :uuid
    end

    # alter table(:projects) do
    # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
    # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
    # remove :selected
    # end
    # 
    # alter table(:accounts) do
    # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
    # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
    # remove :selected
    # end
    # 
  end

  def down do
    # alter table(:accounts) do
    # This is the `down` migration of the statement:
    #
    #     remove :selected
    #
    # 
    # add :selected, :boolean, null: false, default: false
    # end
    # 
    # alter table(:projects) do
    # This is the `down` migration of the statement:
    #
    #     remove :selected
    #
    # 
    # add :selected, :boolean, null: false, default: false
    # end
    # 
    alter table(:users) do
      remove :selected_project_id
      remove :selected_account_id
    end
  end
end
