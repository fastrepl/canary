defmodule Canary.Repo.Migrations.InitResources do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:tokens, primary_key: false) do
      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false
      add :jti, :text, null: false, primary_key: true
    end

    create table(:sources, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid, null: false
      add :name, :text, null: false
      add :type, :text
      add :web_base_url, :text
    end

    create table(:source_documents, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :url, :text
      add :content_hash, :binary, null: false

      add :source_id,
          references(:sources,
            column: :id,
            name: "source_documents_source_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end

    create unique_index(:source_documents, [:content_hash],
             name: "source_documents_unique_content_index"
           )

    create table(:source_chunks, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :content, :text, null: false
      add :embedding, :vector, null: false, size: 384
      add :url, :text

      add :document_id,
          references(:source_documents,
            column: :id,
            name: "source_chunks_document_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end

    create table(:sessions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :discord_id, :bigint
      add :web_id, :text
      add :account_id, :uuid
    end

    create table(:session_messages, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :session_id,
          references(:sessions,
            column: :id,
            name: "session_messages_session_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :role, :text, null: false
      add :content, :text, null: false
    end

    create table(:clients, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid, null: false
      add :name, :text, null: false
      add :type, :text
      add :web_base_url, :text
      add :web_public_key, :text
      add :discord_server_id, :bigint
      add :discord_channel_id, :bigint
    end

    create table(:client_sources, primary_key: false) do
      add :client_id,
          references(:clients,
            column: :id,
            name: "client_sources_client_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          primary_key: true,
          null: false

      add :source_id,
          references(:sources,
            column: :id,
            name: "client_sources_source_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          primary_key: true,
          null: false
    end

    create table(:accounts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:sources) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "sources_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:sources, [:account_id, :name], name: "sources_unique_source_index")

    alter table(:sessions) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "sessions_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:sessions, [:account_id, :discord_id],
             name: "sessions_unique_discord_index"
           )

    create unique_index(:sessions, [:account_id, :web_id], name: "sessions_unique_web_index")

    alter table(:clients) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "clients_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:clients, [:account_id, :name], name: "clients_unique_client_index")

    create unique_index(:clients, [:discord_server_id, :discord_channel_id],
             name: "clients_unique_discord_index"
           )

    create unique_index(:clients, [:web_base_url, :web_public_key],
             name: "clients_unique_web_index"
           )

    alter table(:accounts) do
      add :name, :text, null: false
    end

    create table(:account_users, primary_key: false) do
      add :user_id,
          references(:users,
            column: :id,
            name: "account_users_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :account_id,
          references(:accounts,
            column: :id,
            name: "account_users_account_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end
  end

  def down do
    drop constraint(:account_users, "account_users_user_id_fkey")

    drop constraint(:account_users, "account_users_account_id_fkey")

    drop table(:account_users)

    alter table(:accounts) do
      remove :name
    end

    drop_if_exists unique_index(:clients, [:web_base_url, :web_public_key],
                     name: "clients_unique_web_index"
                   )

    drop_if_exists unique_index(:clients, [:discord_server_id, :discord_channel_id],
                     name: "clients_unique_discord_index"
                   )

    drop_if_exists unique_index(:clients, [:account_id, :name],
                     name: "clients_unique_client_index"
                   )

    drop constraint(:clients, "clients_account_id_fkey")

    alter table(:clients) do
      modify :account_id, :uuid
    end

    drop_if_exists unique_index(:sessions, [:account_id, :web_id],
                     name: "sessions_unique_web_index"
                   )

    drop_if_exists unique_index(:sessions, [:account_id, :discord_id],
                     name: "sessions_unique_discord_index"
                   )

    drop constraint(:sessions, "sessions_account_id_fkey")

    alter table(:sessions) do
      modify :account_id, :uuid
    end

    drop_if_exists unique_index(:sources, [:account_id, :name],
                     name: "sources_unique_source_index"
                   )

    drop constraint(:sources, "sources_account_id_fkey")

    alter table(:sources) do
      modify :account_id, :uuid
    end

    drop table(:accounts)

    drop constraint(:client_sources, "client_sources_client_id_fkey")

    drop constraint(:client_sources, "client_sources_source_id_fkey")

    drop table(:client_sources)

    drop table(:clients)

    drop constraint(:session_messages, "session_messages_session_id_fkey")

    drop table(:session_messages)

    drop table(:sessions)

    drop constraint(:source_chunks, "source_chunks_document_id_fkey")

    drop table(:source_chunks)

    drop_if_exists unique_index(:source_documents, [:content_hash],
                     name: "source_documents_unique_content_index"
                   )

    drop constraint(:source_documents, "source_documents_source_id_fkey")

    drop table(:source_documents)

    drop table(:sources)

    drop table(:tokens)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
