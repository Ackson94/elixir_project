defmodule ProxyWeb.Router do
  use ProxyWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(ProxyWeb.Plugs.SetUser)
    plug(ProxyWeb.Plugs.SessionTimeout, timeout_after_seconds: 3_600)
  end

  pipeline :session do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  pipeline :main_layout do
    plug(:put_layout, {ProxyWeb.LayoutView, :main_layout})
  end

  pipeline :dashboard_layout do
    plug(:put_layout, {ProxyWeb.LayoutView, :dashboard_layout})
  end

  pipeline :api do
    plug :copy_req_body
    plug :accepts, ["json"]
  end

  defp copy_req_body(conn, _) do
    Plug.Conn.put_private(conn, :my_app_body, Plug.Conn.read_body(conn))
  end

  scope "/", ProxyWeb do
    pipe_through([:browser, :main_layout])
    get("/new/user", UserController, :new)
    post("/new/user", UserController, :create)
    get("/all/users", UserController, :list_users)
    get("/update/user", UserController, :edit)
    post("/update/user", UserController, :update)
    delete("/delete/user", UserController, :delete)
    get("/user/activity/logs", UserController, :user_activity)
    get("/activity/logs", UserController, :activity_logs)
    post("/change/user/status", UserController, :update_status)
    get("/new/password", UserController, :new_password)
    post("/new/password", UserController, :change_password)
    post("/reset/password", UserController, :default_password)
    post("/reset/user/password", UserController, :reset_pwd)
  end

  scope "/", ProxyWeb do
    pipe_through([:browser, :dashboard_layout])
    get("/dashboard", UserController, :dashboard)
  end

  scope "/", ProxyWeb do
    pipe_through([:session])
    get("/", SessionController, :new)
    post("/", SessionController, :create)
    get("/forgort/password", UserController, :forgot_password)
    post("/confirmation/token", UserController, :token)
    get("/reset/password", UserController, :default_password)
  end

  scope "/", ProxyWeb do
    pipe_through([:browser])
    get("/logout/current/user", SessionController, :signout)
  end

  # --------------- export routes --------------------------#
  scope "/", ProxyWeb do
    pipe_through([:browser, :main_layout])
    get("/download/csv", ReportController, :csv_exp)
  end

  #------------------------------------------------------------
  scope "/", ProxyWeb do
    pipe_through([:browser, :main_layout])

    get("/mnos", MnoController, :index)
    get("/mno/new", MnoController, :new)
    post("/mno/create", MnoController, :create)
    get("/mno/edit", MnoController, :edit)
    post("/mno/update", MnoController, :update)
    delete("/mno/delete", MnoController, :delete)
  end

  scope "/", ProxyWeb do
    pipe_through([:browser, :main_layout])

    get("/list/transactions", TransferController, :index)
    post("/list/transactions", TransferController, :item_lookup)
    get("/view/transaction/details", TransferController, :view_trans_details)

    #------------archive---------
    get("/list/archive/transactions", TransferController, :archive)
    post("/list/archive/transactions", TransferController, :archive_item_lookup)
    get("/view/archive/transaction/details", TransferController, :view_archive_trans_details)
  end

  scope "/", ProxyWeb do
    pipe_through([:browser, :main_layout])

    get("/core/banking/settings", SettingsController, :cb)
    post("/core/banking/settings", SettingsController, :create_cb)
    get("/sms/notification/settings", SettingsController, :sms)
    post("/sms/notification/settings", SettingsController, :create_sms)
  end

  # Other scopes may use custom stacks.
  scope "/api", ProxyWeb do
    pipe_through(:api)

    post "/probase/proxy/bank_ab/transfer", ApiController, :transfer_request
    post "/probase/proxy/bank_ab/transaction/status", ApiController, :status_request

    get "/probase/proxy/bank_ab/cblogin", ApiController, :cb_login
    post "/probase/proxy/bank_ab/cbtransfer", ApiController, :cb_transfer

    #====== test
    get "/API/Auth/login", ApiController, :login
    get "/API/Customers/Search", ApiController, :customer
    post "/API/Accounts/NameLookup", ApiController, :look
    post "/API/Transactions/Transfers/WalletToBank/Hold", ApiController, :hold
    get "/API/Customers/id/ActiveAccounts", ApiController, :message
  end
end
