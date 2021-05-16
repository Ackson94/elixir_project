defmodule Proxy.Repo.Migrations.CreateTblTransfer do
  use Ecto.Migration

  def change do
    create table(:tbl_transfer) do
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
      add :currency, :string
      add :channel_dtls, :string
      add :narrative, :string
      add :voucher_num, :string
      add :status_code, :string
      add :status_descript, :string
      add :request, :string, size: 3000
      add :cb_request, :string, size: 300
      add :cb_response, :string, size: 300
      add :response, :string, size: 3000

      timestamps()
    end
    create index(:tbl_transfer, [:external_id])

  end
end
