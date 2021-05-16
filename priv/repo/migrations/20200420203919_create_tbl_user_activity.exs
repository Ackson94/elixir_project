defmodule Proxy.Repo.Migrations.CreateTblUserActivity do
  use Ecto.Migration

  def change do
    create table(:tbl_user_activity) do
      add :activity, :string
      add :user_id, references(:tbl_users, column: :id, on_delete: :delete_all)

      timestamps()
    end

  end
end
