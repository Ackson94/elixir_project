defmodule Proxy.Jobs.Archive do
  require Logger
  import Ecto.Query, warn: false
  alias Proxy.{Repo, Transactions}

  @qty 700

  def perform do
    queryable = &Transactions.delete_archived_logs/1

    Transactions.get_transactions_to_archive()
    |> Repo.all()
    |> Enum.chunk_every(@qty)
    |> Enum.map(fn result ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, "tbl_archive", result)
      |> Ecto.Multi.delete_all(:delete_all, queryable.(Enum.map(result, &(&1.id))))
      |> Repo.transaction()
    end)
  end

end
