defmodule Proxy.Repo.Migrations.CreateTblEmailNotificationLogs do
  use Ecto.Migration

  def change do
    create table(:tbl_email_notification_logs) do
      add :email, :string
      add :bank_code, :string

      timestamps()
    end
    
  end
end
