defmodule Proxy.Repo.Migrations.CreateTblArchive do
  use Ecto.Migration

  def change do
    create table(:tbl_archive, primary_key: false) do
      add :id, :id, primary_key: true
      add :external_id, :string
      add :acc_num, :string
      add :transmission_dt_time, :naive_datetime
      add :ref_num, :string
      add :mobile_num, :string
      add :vendor_code, :string
      add :provider, :string
      add :channel_code, :string
      add :amount, :decimal, precision: 18 , scale: 2
      add :balance, :decimal, precision: 18 , scale: 2
      add :status_descript, :string
      add :currency, :string
      add :channel_dtls, :string
      add :narrative, :string
      add :voucher_num, :string
      add :status_code, :string
      add :request, :string, size: 3000
      add :cb_request, :string, size: 300
      add :cb_response, :string, size: 300
      add :response, :string, size: 3000
      add :inserted_at, :naive_datetime
      add :updated_at, :naive_datetime

    end
    create index(:tbl_archive, [:external_id])
  end
end
