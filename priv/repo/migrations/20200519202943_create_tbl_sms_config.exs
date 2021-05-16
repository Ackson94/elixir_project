defmodule Proxy.Repo.Migrations.CreateTblSmsConfig do
  use Ecto.Migration

  def change do
    create table(:tbl_sms_config) do
      add :username, :string
      add :password, :string
      add :sender_id, :string
      add :url, :string

      timestamps()
    end

  end
end
