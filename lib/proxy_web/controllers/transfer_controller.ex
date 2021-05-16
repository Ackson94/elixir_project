defmodule ProxyWeb.TransferController do
  use ProxyWeb, :controller

  alias Proxy.Transactions

  plug(
    ProxyWeb.Plugs.RequireAuth
    when action in [:index, :view_trans_details, :item_lookup]
  )

  plug(
    ProxyWeb.Plugs.EnforcePasswordPolicy
    when action not in [:new_password, :change_password]
  )

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def view_trans_details(conn, %{"id" => id}) do
    txn_details = Transactions.get_transfer!(id)
    render(conn, "view_trans_details.html", txn_details: txn_details)
  end

  def item_lookup(conn, params) do
    {draw, start, length, search_params} = search_options(params)
    lookup = confirm_report_type(conn.request_path)

    results =
      lookup.(search_params, start, length)

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  defp confirm_report_type("/list/transactions"), do: &Transactions.get_all_complete_trans/3


  def total_entries(%{total_entries: total_entries}), do: total_entries
  def total_entries(_), do: 0

  def entries(%{entries: entries}), do: entries
  def entries(_), do: []

  def search_options(params) do
    length = calculate_page_size(params["length"])
    page = calculate_page_num(params["start"], length)
    draw = String.to_integer(params["draw"])
    params = Map.put(params, "isearch", params["search"]["value"])

    new_params =
      Enum.reduce(~w(columns order search length draw start _csrf_token), params, fn key, acc ->
        Map.delete(acc, key)
      end)

    {draw, page, length, new_params}
  end

  def calculate_page_num(nil, _), do: 1

  def calculate_page_num(start, length) do
    start = String.to_integer(start)
    round(start / length + 1)
  end

  def calculate_page_size(nil), do: 10
  def calculate_page_size(length), do: String.to_integer(length)

  # defp confirm_source("/export/items"), do: @current
  # defp confirm_source(_), do: @current


  #---------------------------------------- ARCHIVE---------------------------------------/view/archive/transaction/details
  def archive(conn, _params) do
    render(conn, "archive.html")
  end

  def view_archive_trans_details(conn, %{"id" => id}) do
    txn_details = Transactions.get_archive!(id)
    render(conn, "view_archive_details.html", txn_details: txn_details)
  end

  def archive_item_lookup(conn, params) do
    {draw, start, length, search_params} = search_options(params)
    lookup = confirm_report_type(conn.request_path)

    results =
      lookup.(search_params, start, length)

    total_entries = total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: entries(results)
    }

    json(conn, results)
  end

  defp confirm_report_type("/list/archive/transactions"), do: &Transactions.get_archived_transactions/3







  def b() do
    for a <- 1..50 do
      Transactions.create_archive()
    end
  end
end
