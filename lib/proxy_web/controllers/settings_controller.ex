defmodule ProxyWeb.SettingsController do
  use ProxyWeb, :controller

  alias Proxy.Repo 
  alias Proxy.Activity.UserLog
  alias Proxy.Settings
  alias Proxy.Settings.{Sms, CoreBanking}
 
  plug(
    ProxyWeb.Plugs.RequireAuth
    when action in [:cb, :create_cb, :sms, :create_sms]
  )
 
  plug(
    ProxyWeb.Plugs.EnforcePasswordPolicy
    when action not in [:new_password, :change_password]
  )

  # plug(ProxyWeb.Plugs.RequireOpsAccess when action not in [:dashboard])

  def cb(conn, _params) do
    cb_configs = Settings.cb_configs()
    render(conn, "core_bank.html", cb_configs: cb_configs)
  end

  def create_cb(conn, params) do
      cb_configs = params["id"] != "" && Settings.cb_configs() || %CoreBanking{}
      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(:cb_configs, CoreBanking.changeset(cb_configs, params))
      |> Ecto.Multi.run(:user_log, fn %{cb_configs: _sms_configs} ->
        activity = "Created/Updated with Core Banking information"
        UserLog.changeset(%UserLog{}, %{
          user_id: conn.assigns.user.id,
          activity: activity
        })
        |> Repo.insert()
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{cb_configs: _cb_configs, user_log: _user_log}} ->
          conn
          |> put_flash(:info, "Operation successful!")
          |> redirect(to: Routes.settings_path(conn, :cb))

        {:error, _failed_operation, failed_value, _changes_so_far} ->
          reason = traverse_errors(failed_value.errors) |> Enum.join("\r\n")

          conn
          |> put_flash(:error, reason)
          |> redirect(to: Routes.settings_path(conn, :cb))
      end
  rescue
  _ ->
      conn
      |> put_flash(:error, "An error occurred, reason unknown. try again")
      |> redirect(to: Routes.settings_path(conn, :cb))
  end

  def sms(conn, _params) do
    sms_configs = Settings.sms_configs()
    render(conn, "sms.html", sms_configs: sms_configs)
  end

  def create_sms(conn, params) do
      sms_configs = params["id"] != "" && Settings.sms_configs() || %Sms{}
      Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(:sms_configs, Sms.changeset(sms_configs, params))
      |> Ecto.Multi.run(:user_log, fn %{sms_configs: _sms_configs} ->
        activity = "Created/Updated with sms information"
        UserLog.changeset(%UserLog{}, %{
          user_id: conn.assigns.user.id,
          activity: activity
        })
        |> Repo.insert()
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{sms_configs: _sms_configs, user_log: _user_log}} ->
          conn
          |> put_flash(:info, "Operation successful!")
          |> redirect(to: Routes.settings_path(conn, :sms))

        {:error, _failed_operation, failed_value, _changes_so_far} ->
          reason = traverse_errors(failed_value.errors) |> Enum.join("\r\n")

          conn
          |> put_flash(:error, reason)
          |> redirect(to: Routes.settings_path(conn, :sms))
      end
  rescue
  _ ->
      conn
      |> put_flash(:error, "An error occurred, reason unknown. try again")
      |> redirect(to: Routes.settings_path(conn, :sms))
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end
end
