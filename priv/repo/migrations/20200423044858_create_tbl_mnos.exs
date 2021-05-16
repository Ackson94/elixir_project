defmodule Proxy.Repo.Migrations.Mnos do
  use Ecto.Migration

  def change do
    create table(:tbl_mnos) do
      add :username, :string
      add :password, :string
      add :access_token, :string
      add :bank_username, :string
      add :bank_password, :string
      add :vendor_code, :string
      add :provider, :string
      add :channel_code, :string
      add :channel_details, :string
      add :user_id, references(:tbl_users, column: :id, on_delete: :nilify_all)

      timestamps()
    end

  end
end
