defmodule ProxyWeb.ReportController do
  use ProxyWeb, :controller
  alias Proxy.Repo
  alias Proxy.Transactions
  alias Proxy.Transactions.Transfer

  plug(ProxyWeb.Plugs.RequireAuth when action in [:csv_exp])

  plug(
    ProxyWeb.Plugs.EnforcePasswordPolicy
    when action not in [:new_password, :change_password]
  )

  # plug(ProxyWeb.Plugs.RequireOpsAccess when action not in [:dashboard])

  @current "tbl_transfer"

  @headers ~w(
    external_id acc_num transmission_dt_time vendor_code provider
    amount narrative voucher_num status_descript
  )a

  # def excel_exp(conn, params) do
  #   entries =
  #     process_report(conn, @current, params)
  #     |> Transactions.get_all_complete_trans(Map.put(params, "isearch", ""), "/report/entries")
  #   conn
  #   |> put_resp_content_type("text/xlsx")
  #   |> put_resp_header("content-disposition", "attachment; filename=BANKLINK_REPORT_#{Timex.today()}.xlsx")
  #   |> render("report.xlsx", %{entries: entries})
  # end


  def csv_exp(conn, params) do
    process_report(conn, @current, params)
  end

  defp process_report(conn, source, params) do
    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=PROXY_REPORT_#{Timex.today()}.csv"
      )
      |> put_resp_content_type("text/csv")

    csv_content =
      params
      |> Map.delete("_csrf_token")
      |> report_generator(source)
      |> Repo.all()
      |> CSV.encode(headers: @headers)
      |> Enum.to_list()
      |> to_string

    send_resp(conn, 200, csv_content)
  end

  def report_generator(search_params, source) do
    Transactions.get_all_complete_trans(source, Map.put(search_params, "isearch", ""))
  end
end
