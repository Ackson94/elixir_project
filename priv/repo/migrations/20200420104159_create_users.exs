defmodule Proxy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:tbl_users) do
      add :username, :string
      add :password, :string
      add :auto_password, :string
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :user_role, :integer
      add :user_type, :integer
      add :status, :integer
      add :user_id, :id

      timestamps()
    end
  end
end
