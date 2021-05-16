defmodule Proxy.Repo.Migrations.AddUniqueIndexEmailTblUsers do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_users, [:email], name: :unique_email_tbl_users, where: "status != 3")
  end

  def down do
    create unique_index(:tbl_users, [:email], name: :unique_email_tbl_users, where: "status != 3")
  end
end
