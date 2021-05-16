defmodule ProxyWeb.UserController do
  use ProxyWeb, :controller
  import Ecto.Query, warn: false

  alias Proxy.Accounts
  alias Proxy.Repo
  alias Proxy.Accounts.User
  alias Proxy.Activity
  alias Proxy.{Accounts, Repo, Activity.UserLog, Auth}
  alias Proxy.Emails.Email
  # alias Proxy.Emails.Mailer
  alias Proxy.Transactions

  plug(
    ProxyWeb.Plugs.RequireAuth
    when action in [
           :new,
           :dashboard,
           :change_password,
           :new_password,
           :list_users,
           :edit,
           :delete,
           :user_logs,
           :update,
           :create,
           :update_status,
           :user_activity
         ]
  )

  plug(
    ProxyWeb.Plugs.EnforcePasswordPolicy
    when action not in [:new_password, :change_password]
  )

  # plug(
  #   ProxyWeb.Plugs.RequireAdminAccess
  #   when action not in [:new_password, :change_password, :dashboard, :user_actitvity]
  # )

  # plug(
  #   BankLinkWeb.Plugs.RequireOpsAccess
  #   when action in [:dashboard]
  # )

  def dashboard(conn, _params) do
    IO.inspect conn
    summary = Transactions.dashboard_params() |> prepare_dash_result()

    keys = Enum.map(summary, &(&1.day)) |> Enum.uniq |> Enum.sort()
    success = Enum.sort_by(summary, &(&1.day))  |> Enum.filter(&(&1.status == "SUCCESS")) |> Enum.map(&(&1.count))
    failed = Enum.sort_by(summary, &(&1.day))  |> Enum.filter(&(&1.status == "FAILED")) |> Enum.map(&(&1.count))
    render(conn, "dashboard.html", success: success, failed: failed, keys: keys)
  end

  defp prepare_dash_result(results) do
    Enum.reduce(default_dashboard(), results, fn item, acc ->
      filtered = Enum.filter(acc, &(&1.day == item.day && &1.status == "SUCCESS"))
      if item not in acc && Enum.empty?(filtered), do: [item | acc], else: acc
    end)
    |> Enum.sort_by(& &1.day)
  end

  defp default_dashboard do
    today = Date.utc_today()
    days = Date.days_in_month(today)

    Date.range(%{today | day: 1}, %{today | day: days})
    |> Enum.map(&%{count: 0, day: Timex.format!(&1, "%b #{String.pad_leading(to_string(&1.day), 2, "0")}, %Y", :strftime), status: "SUCCESS"})
  end

  def list_users(conn, _params) do
    users =
      Accounts.get_all_users()
      |> Enum.map(&%{&1 | id: sign_user_id(conn, &1.id)})
    render(conn, "list_users.html", users: users)
  end

  def user_activity(conn, %{"id" => user_id}) do
    with :error <- confirm_token(conn, user_id) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :list_users))
    else
      {:ok, user} ->
        user_logs = Activity.get_user_logs_by(user.id)
        render(conn, "activity_logs.html", user_logs: user_logs)
    end
  end

  def activity_logs(conn, _params) do
    results = Activity.get_all_activity_logs()
    render(conn, "activity_logs.html", user_logs: results)
  end

  def update_status(conn, %{"id" => id, "status" => status}) do
    with :error <- confirm_token(conn, id) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :list_users))
    else
      {:ok, user} ->
        User.changeset(user, %{status: status})
        |> prepare_status_change(conn, user, status)
        |> Repo.transaction()
        |> case do
          {:ok, %{user: _user, user_log: _user_log}} ->

              case status do
                "1" ->
                  conn
                  |> json(%{"error" => "#{String.capitalize(user.first_name)} Activated successfully."})
                _ ->
                  conn
                  |> json(%{"error" => "#{String.capitalize(user.first_name)} Deleted successfully."})
              end

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            reason = traverse_errors(failed_value.errors) |> List.first()

            conn
            |> put_flash(:error, reason)
            |> redirect(to: Routes.user_path(conn, :list_users))
        end
    end
  end

  defp prepare_status_change(changeset, conn, user, status) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.insert(
      :user_log,
      UserLog.changeset(
        %UserLog{},
        %{
          user_id: conn.assigns.user.id,
          activity: """
          #{
            case status,
              do:
                (
                  "1" -> "Activated"
                  _ -> "Deleted"
                )
          }
          #{user.first_name} #{user.last_name}
          """
        }
      )
    )
  end

  def edit(conn, %{"id" => id}) do
    with :error <- confirm_token(conn, id) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :list_users))
    else
      {:ok, user} ->
        user = %{user | id: sign_user_id(conn, user.id)}
        render(conn, "edit.html", result: user)
    end
  end

  def update(conn, %{"user" => user_params}) do
    with :error <- confirm_token(conn, user_params["id"]) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :list_users))
    else
      {:ok, user} ->
        Ecto.Multi.new()
        |> Ecto.Multi.update(:update, User.changeset(user, Map.delete(user_params, "id")))
        |> Ecto.Multi.run(:log, fn %{update: _update} ->
          activity =
            "Modified user details with Email \"#{user.email}\" and First Name \"#{
              user.first_name
            }\""

          user_log = %{
            user_id: conn.assigns.user.id,
            activity: activity
          }

          UserLog.changeset(%UserLog{}, user_log)
          |> Repo.insert()
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{update: _update, log: _log}} ->
            conn
            |> put_flash(:info, "Changes applied successfully!")
            |> redirect(to: Routes.user_path(conn, :edit, id: user_params["id"]))

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            reason = traverse_errors(failed_value.errors) |> List.first()

            conn
            |> put_flash(:error, reason)
            |> redirect(to: Routes.user_path(conn, :edit, id: user_params["id"]))
        end
    end
  rescue
    _ ->
      conn
      |> put_flash(:error, "An error occurred, reason unknown")
      |> redirect(to: Routes.user_path(conn, :list_users))
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => user_params}) do
    pwd = random_string(6)
    user_params = Map.put(user_params, "password", pwd)
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.changeset(%User{user_id: conn.assigns.user.id}, user_params))
    |> Ecto.Multi.run(:user_log, fn %{user: user} ->
      activity =
        "Created new user with Email \"#{user.email}\" and First Name #{user.first_name}\""

      user_log = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, user_log: _user_log}} ->
        Email.password_alert(user.email, pwd, user.username)
        conn
        |> put_flash(
          :info,
          # "#{String.capitalize(user.first_name)} created successfully"
          "#{String.capitalize(user.first_name)} created successfully and password is: #{pwd}"
        )
        |> redirect(to: Routes.user_path(conn, :new))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_path(conn, :new))
    end
  rescue
    _ ->
      conn
      |> put_flash(:error, "An error occurred, reason unknown. try again")
      |> redirect(to: Routes.user_path(conn, :list_users))
  end

  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "invalid email address"}
      user -> {:ok, user}
    end
  end

  def get_user_by(username) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, "invalid username/password"}
      user -> {:ok, user}
    end
  end

  defp sign_user_id(conn, id),
    do: Phoenix.Token.sign(conn, "user salt", id, signed_at: System.system_time(:second))

  # ------------------ Password Reset ---------------------
  def new_password(conn, _params) do
    render(conn, "change_password.html")
  end

  def forgot_password(conn, _params) do
    conn
    |> put_layout(false)
    |> render("forgot_password.html")
  end

  def token(conn, %{"user" => user_params}) do
    with {:error, reason} <- get_user_by_email(user_params["email"]) do
      conn
      |> put_flash(:error, reason)
      |> redirect(to: Routes.user_path(conn, :forgot_password))
    else
      {:ok, user} ->
        token =
          Phoenix.Token.sign(conn, "user salt", user.id, signed_at: System.system_time(:second))

        Email.confirm_password_reset(token, user.email)

        conn
        |> put_flash(:info, "We have sent you a mail")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  defp confirm_token(conn, token) do
    case Phoenix.Token.verify(conn, "user salt", token, max_age: 86400) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        {:ok, user}

      {:error, _} ->
        :error
    end
  end

  def default_password(conn, %{"token" => token}) do
    with :error <- confirm_token(conn, token) do
      conn
      |> put_flash(:error, "Invalid/Expired token")
      |> redirect(to: Routes.user_path(conn, :forgot_password))
    else
      {:ok, user} ->
        pwd = random_string(6)

        case Accounts.update_user(user, %{password: pwd, auto_password: "Y"}) do
          {:ok, _user} ->
            Email.password_alert(user.email, pwd, user.username)

            conn
            |> put_flash(:info, "Password reset successful")
            |> redirect(to: Routes.session_path(conn, :new))

          {:error, _reason} ->
            conn
            |> put_flash(:error, "An error occured, try again!")
            |> redirect(to: Routes.user_path(conn, :forgot_password))
        end
    end
  end

  def reset_pwd(conn, %{"id" => id}) do
    with :error <- confirm_token(conn, id) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :list_users))
    else
      {:ok, user} ->
        pwd = random_string(6)
        changeset = User.changeset(user, %{password: pwd, auto_password: "Y"})

        Ecto.Multi.new()
        |> Ecto.Multi.update(:user, changeset)
        |> Ecto.Multi.insert(
          :user_log,
          UserLog.changeset(
            %UserLog{},
            %{
              user_id: conn.assigns.user.id,
              activity: """
              Reserted account password for user with mail \"#{user.email}\"
              """
            }
          )
        )
        |> Repo.transaction()
        |> case do
          {:ok, %{user: user, user_log: _user_log}} ->
            Email.password_alert(user.email, pwd, user.username)
            conn |> json(%{"error" => "Password changed to: #{pwd}"})
          # conn |> json(%{"info" => "Password changed successfully"})

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            reason = traverse_errors(failed_value.errors) |> List.first()
            conn |> json(%{"error" => reason})
        end
    end
  end

  def change_password(conn, %{"user" => user_params}) do
    case confirm_old_password(conn, user_params) do
      false ->
        conn
        |> put_flash(:error, "some fields were submitted empty!")
        |> redirect(to: Routes.user_path(conn, :new_password))

      result ->
        with {:error, reason} <- result do
          conn
          |> put_flash(:error, reason)
          |> redirect(to: Routes.user_path(conn, :new_password))
        else
          {:ok, _} ->
            conn.assigns.user
            |> change_pwd(user_params)
            |> Repo.transaction()
            |> case do
              {:ok, %{update: _update, insert: _insert}} ->
                conn
                |> put_flash(:info, "Password changed successful")
                |> redirect(to: Routes.user_path(conn, :new_password))

              {:error, _failed_operation, failed_value, _changes_so_far} ->
                reason = traverse_errors(failed_value.errors) |> List.first()

                conn
                |> put_flash(:error, reason)
                |> redirect(to: Routes.user_path(conn, :new_password))
            end
        end
    end
  rescue
    _ ->
      conn
      |> put_flash(:error, "Password changed with errors")
      |> redirect(to: Routes.user_path(conn, :new_password))
  end

  def change_pwd(user, user_params) do
    pwd = String.trim(user_params["new_password"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, User.changeset(user, %{password: pwd, auto_password: "N"}))
    |> Ecto.Multi.insert(
      :insert,
      UserLog.changeset(
        %UserLog{},
        %{user_id: user.id, activity: "changed account password"}
      )
    )
  end

  defp confirm_old_password(
         conn,
         %{"old_password" => pwd, "new_password" => new_pwd}
       ) do
    with true <- String.trim(pwd) != "",
         true <- String.trim(new_pwd) != "" do
      Auth.confirm_password(
        conn.assigns.user,
        String.trim(pwd)
      )
    else
      false -> false
    end
  end

  # ------------------ / password reset -------------------
  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
