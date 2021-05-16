defmodule Proxy.Repo.Migrations.AddUniqueIndexUsernameTblUsers do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_users, [:username], name: :unique_username_tbl_users, where: "status != 3")
  end

  def down do
    create unique_index(:tbl_users, [:username], name: :unique_username_tbl_users, where: "status != 3")
  end
end
