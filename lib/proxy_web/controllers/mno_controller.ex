defmodule ProxyWeb.MnoController do
  use ProxyWeb, :controller
  alias Proxy.Accounts
  alias Proxy.Accounts.Mno
  alias Proxy.{Repo, Activity.UserLog, Auth}
  alias ProxyWeb.UserController


  plug(
    ProxyWeb.Plugs.RequireAuth
    when action in [:index, :new, :edit, :create, :delete, :update]
  )

  plug(
    ProxyWeb.Plugs.EnforcePasswordPolicy
    when action not in [:new_password, :change_password]
  )

  # plug(
  #   ProxyWeb.Plugs.RequireAdminAccess
  #   when action not in [:new_password]
  # )

  def index(conn, _params) do
    mnos = Accounts.list_tbl_mnos()
    page = %{first: "MNOs", last: "View MNO"}
    render(conn, "index.html", mnos: mnos, page: page)
  end

  def new(conn, _params) do
    page = %{first: "MNOs", last: "Add MNO"}
    render(conn, "new.html", page: page)
  end

  def edit(conn, %{"id" => id}) do
    mno = Accounts.get_mno!(id)
    page = %{first: "MNOs", last: "Update MNO"}
    render(conn, "edit.html", mno: mno, page: page)
  end

  def create(conn, %{"mno" => params}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :mno,
      Mno.changeset(%Mno{user_id: conn.assigns.user.id}, params)
    )
    |> Ecto.Multi.run(:User_log, fn %{mno: mno} ->
      activity = "Created new MNO with Username \"#{mno.username}\""

      UserLog.changeset(%UserLog{}, %{
        user_id: conn.assigns.user.id,
        activity: activity
      })
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{mno: _mno, User_log: _User_log}} ->
        conn
        |> put_flash(:info, "MNO created successfully.")
        |> redirect(to: Routes.mno_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = UserController.traverse_errors(failed_value.errors) |> Enum.join(" | ")

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.mno_path(conn, :new))
    end
  rescue
    _error ->
      conn
      |> put_flash(:error, "An error occurred, reason unknown. try again")
      |> redirect(to: Routes.mno_path(conn, :new))
  end

  def update(conn, %{"mno" => params}) do
    mno = Accounts.get_mno!(params["id"])
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Mno.changeset(mno, params))
    |> Ecto.Multi.run(:log, fn %{update: mno} ->
      activity = """
      Modified MNO, with username \"#{mno.username}\"
      to \"#{mno.username}\""
      """

      UserLog.changeset(%UserLog{}, %{
        user_id: conn.assigns.user.id,
        activity: activity
      })
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: update, log: _log}} ->
        conn
        |> put_flash(:info, "Changes applied successfully!")
        |> redirect(to: Routes.mno_path(conn, :edit, id: update.id))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = UserController.traverse_errors(failed_value.errors) |> Enum.join(" | ")
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.mno_path(conn, :edit, id: mno.id))
    end
    rescue
      _error ->
        conn
        |> put_flash(:error, "An error occurred, reason unknown. try again")
        |> redirect(to: Routes.mno_path(conn, :edit, id: params["id"]))
  end

  def delete(conn, %{"id" => id}) do
    mno = Accounts.get_mno!(id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, mno)
    |> Ecto.Multi.run(:User_log, fn %{del: del} ->
      activity = "Deleted MNO with username \"#{del.username}\""

      UserLog.changeset(%UserLog{}, %{
        user_id: conn.assigns.user.id,
        activity: activity
      })
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, User_log: _User_log}} ->
        conn |> json(%{"info" => "MNO deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = UserController.traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  rescue
    _ ->
      conn |> json(%{"error" => "An error occurred."})
  end

  def get_by_username(username) do
    case Repo.get_by(Mno, username: String.downcase(username)) do
      nil -> {:error, "invalid username"}
      mno -> {:ok, mno}
    end
  end
end
