defmodule Proxy.Repo.Migrations.CreateVwDashoardParams do
  use Ecto.Migration

  def change do
    execute """
    CREATE VIEW [dbo].[vw_dashboard_params] AS(
      select
              *
              FROM
                  tbl_transfer
              WHERE
                status_code IS NOT NULL and amount IS NOT NULL
    )
    """,
    "DROP VIEW [dbo].[vw_dashboard_params]"
  end
end
