defmodule Proxy.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Proxy.Repo


  alias Proxy.Transactions.Transfer
  alias Proxy.Transactions.Archive

  @doc """
  Returns the list of tbl_transfer.

  ## Examples

      iex> list_tbl_transfer()
      [%Transfer{}, ...]

  """
  def list_tbl_transfer do
    Repo.all(Transfer)
  end

  @doc """
  Gets a single transfer.

  Raises `Ecto.NoResultsError` if the Request content does not exist.

  ## Examples

      iex> get_transfer!(123)
      %Transfer{}

      iex> get_transfer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transfer!(id), do: Repo.get!(Transfer, id)
  def get_archive!(id), do: Repo.get!(Archive, id)

  @doc """
  Creates a transfer.

  ## Examples

      iex> create_transfer(%{field: value})
      {:ok, %Transfer{}}

      iex> create_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transfer(attrs \\ %{}) do
    %Transfer{}
    |> Transfer.changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  Updates a transfer.

  ## Examples

      iex> update_transfer(transfer, %{field: new_value})/usr/bin/sudo su #will go to the root user
      {:ok, %Transfer{}}

      iex> update_transfer(transfer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transfer(%Transfer{} = transfer, attrs) do
    transfer
    |> Transfer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transfer.

  ## Examples

      iex> delete_transfer(transfer)
      {:ok, %Transfer{}}

      iex> delete_transfer(transfer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transfer(%Transfer{} = transfer) do
    Repo.delete(transfer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transfer changes.

  ## Examples

      iex> change_transfer(transfer)
      %Ecto.Changeset{source: %Transfer{}}

  """
  def change_transfer(%Transfer{} = transfer) do
    Transfer.changeset(transfer, %{})
  end

  def dashboard_params do
    "vw_dashboard_params"
    |> join(
      :right,
      [c],
      day in fragment("""
      SELECT CAST(DATEADD(DAY, nbr - 1, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0)) AS DATE) d
      FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY c.object_id) AS Nbr
        FROM sys.columns c
      ) nbrs
      WHERE nbr - 1 <= DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0), EOMONTH(CAST(CURRENT_TIMESTAMP AS DATETIME)))
      """),
      day.d == fragment("CAST(? AS DATE)", c.inserted_at)
    )
    |> group_by([c, day], [day.d, fragment("CASE
          WHEN ? = '200'
              THEN 'SUCCESS'
          ELSE 'FAILED'
      END", c.status_code)
    ])
    |> order_by([_c, day], day.d)
    |> select([c, day], %{
      day: fragment("convert(varchar, ?, 107)", day.d),
      count: count(c.id),
      status: fragment("""
        CASE
            WHEN ? = '200'
                THEN 'SUCCESS'
            ELSE 'FAILED'
        END
        """, c.status_code
      )
    })
    |> Repo.all()
  end

  def get_all_complete_trans(search_params, page, size) do
    Transfer
    |> where([a], a.status_code != "" and a.amount != 0)
    |> handle_report_filter(search_params)
    |> order_by(desc: :inserted_at)
    |> compose_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  #CSV Report
  def get_all_complete_trans(_source, search_params) do
    Transfer
    |> where([a], a.status_code != "" and a.amount != 0)
    |> handle_report_filter(search_params)
    |> order_by(desc: :inserted_at)
    |> compose_report_select()
  end

  def get_archived_transactions(search_params, page, size) do
    Archive
    |> where([a], a.status_code != "" and a.amount != 0)
    |> handle_report_filter(search_params)
    |> order_by(desc: :inserted_at)
    |> compose_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end




  defp handle_report_filter(query, %{"isearch" => search_term} = search_params)
  when search_term == "" or is_nil(search_term) do
  query
  |> handle_date_filter(search_params)
  |> handle_acc_num_filter(search_params)
  |> handle_mobile_num_filter(search_params)
  |> handle_vendor_code_filter(search_params)
  |> handle_status_filter(search_params)
  end

  defp handle_report_filter(query, %{"isearch" => search_term}) do
  search_term = "%#{search_term}%"
  compose_isearch_filter(query, search_term)
  end

  defp handle_date_filter(query, %{"from" => from, "to" => to})
        when from == "" or is_nil(from) or to == "" or is_nil(to),
        do: query

  defp handle_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_acc_num_filter(query, %{"acc_num" => acc_num})
       when acc_num == "" or is_nil(acc_num),
       do: query

  defp handle_acc_num_filter(query, %{"acc_num" => acc_num}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.acc_num, ^"%#{acc_num}%"))
  end

  defp handle_mobile_num_filter(query, %{"mobile_num" => mobile_num})
       when mobile_num == "" or is_nil(mobile_num),
       do: query

  defp handle_mobile_num_filter(query, %{"mobile_num" => mobile_num}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.mobile_num, ^"%#{mobile_num}%"))
  end

  defp handle_vendor_code_filter(query, %{"vendor_code" => vendor_code})
      when vendor_code == "" or is_nil(vendor_code),
      do: query

  defp handle_vendor_code_filter(query, %{"vendor_code" => vendor_code}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.vendor_code, ^"%#{vendor_code}%"))
  end

  defp handle_status_filter(query, %{"status_code" => status_code})
      when status_code == "" or is_nil(status_code),
      do: query

  defp handle_status_filter(query, %{"status_code" => "400"}) do
    where(query, [a], a.status_code !="200")
  end

  defp handle_status_filter(query, %{"status_code" => status_code}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.status_code, ^"%#{status_code}%"))
  end

  defp compose_isearch_filter(query, search_term) do
    query
    |> where(
      [a],
      fragment("lower(?) LIKE lower(?)", a.vendor_code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.acc_num, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.mobile_num, ^search_term) or
        fragment("CAST(? AS varchar) LIKE ?", a.status_code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.ref_num, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.amount, ^search_term)
    )
  end

  defp compose_report_select(query) do
    query
    |> select(
      [a],
      map(a, [
        :id,
        :acc_num,
        :amount,
        :channel_code,
        :channel_dtls,
        :currency,
        :external_id,
        :mobile_num,
        :narrative,
        :provider,
        :ref_num,
        :status_code,
        :transmission_dt_time,
        :vendor_code,
        :voucher_num,
        :balance,
        :status_descript,
        :inserted_at,
        :updated_at
      ])
    )
  end

  # get transfer by external ID
  def get_transfer_by_ext_id(external_id), do: Repo.get_by(Transfer, external_id: external_id)



  # ------------------------------------ archive -----------------------------#
  # def get_transactions_to_archive do
  #   Transfer
  #   |> where([t], t.transmission_dt_time < ^NaiveDateTime.add(Timex.now, -15552000, :second)) #select transactions done six months ago
  #   |> compose_backup_query()
  # end

  def get_transactions_to_archive do
    Transfer
    |> where([t], fragment(
      "CAST(? AS DATE) < CAST(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, -5, GETDATE())), 0) AS DATE)",
      t.inserted_at
      )) #select transactions done six months ago
    |> compose_backup_query()
  end

  defp compose_backup_query(query) do
    query
    |> order_by([t], t.id)
    |> limit(10_000)
    |> select(
      [t],
      map(
        t,
        [
          :id,
          :external_id,
          :acc_num,
          :amount,
          :currency,
          :mobile_num,
          :narrative,
          :channel_code,
          :channel_dtls,
          :provider,
          :vendor_code,
          :ref_num,
          :transmission_dt_time,
          :voucher_num,
          :balance,
          :status_code,
          :status_descript,
          :request,
          :cb_request,
          :cb_response,
          :response,
          :inserted_at,
          :updated_at
        ]
      )
    )
  end

  def delete_archived_logs(transfer_ids) do
    Transfer |> where([t], t.id in ^transfer_ids)
  end

end
