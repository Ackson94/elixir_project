defmodule Proxy.Repo.Migrations.CreateTblCbConfig do
  use Ecto.Migration

  def change do
    create table(:tbl_cb_config) do
      add :username, :string
      add :password, :string
      add :login_url, :string
      add :name_lkup_url, :string
      add :fund_transf_url, :string

      timestamps()
    end

  end
end
