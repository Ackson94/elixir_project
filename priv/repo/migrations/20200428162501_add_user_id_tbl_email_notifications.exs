defmodule Proxy.Repo.Migrations.AddUserIdTblEmailNotifications do
  use Ecto.Migration

  def change do
    alter table(:tbl_email_notification_logs) do
      add :user_id, references(:tbl_users, column: :id, on_delete: :nilify_all)
    end
  end
end
