defmodule ProxyWeb.ApiUserControllerTest do
  use ProxyWeb.ConnCase

  alias Proxy.Accounts

  @create_attrs %{access_token: "some access_token", bank_password: "some bank_password", bank_username: "some bank_username", password: "some password", username: "some username", vendor_code: "some vendor_code"}
  @update_attrs %{access_token: "some updated access_token", bank_password: "some updated bank_password", bank_username: "some updated bank_username", password: "some updated password", username: "some updated username", vendor_code: "some updated vendor_code"}
  @invalid_attrs %{access_token: nil, bank_password: nil, bank_username: nil, password: nil, username: nil, vendor_code: nil}

  def fixture(:api_user) do
    {:ok, api_user} = Accounts.create_api_user(@create_attrs)
    api_user
  end

  describe "index" do
    test "lists all tbl_api_users", %{conn: conn} do
      conn = get(conn, Routes.api_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl api users"
    end
  end

  describe "new api_user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.api_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New Api user"
    end
  end

  describe "create api_user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), api_user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.api_user_path(conn, :show, id)

      conn = get(conn, Routes.api_user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Api user"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), api_user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Api user"
    end
  end

  describe "edit api_user" do
    setup [:create_api_user]

    test "renders form for editing chosen api_user", %{conn: conn, api_user: api_user} do
      conn = get(conn, Routes.api_user_path(conn, :edit, api_user))
      assert html_response(conn, 200) =~ "Edit Api user"
    end
  end

  describe "update api_user" do
    setup [:create_api_user]

    test "redirects when data is valid", %{conn: conn, api_user: api_user} do
      conn = put(conn, Routes.api_user_path(conn, :update, api_user), api_user: @update_attrs)
      assert redirected_to(conn) == Routes.api_user_path(conn, :show, api_user)

      conn = get(conn, Routes.api_user_path(conn, :show, api_user))
      assert html_response(conn, 200) =~ "some updated access_token"
    end

    test "renders errors when data is invalid", %{conn: conn, api_user: api_user} do
      conn = put(conn, Routes.api_user_path(conn, :update, api_user), api_user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Api user"
    end
  end

  describe "delete api_user" do
    setup [:create_api_user]

    test "deletes chosen api_user", %{conn: conn, api_user: api_user} do
      conn = delete(conn, Routes.api_user_path(conn, :delete, api_user))
      assert redirected_to(conn) == Routes.api_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.api_user_path(conn, :show, api_user))
      end
    end
  end

  defp create_api_user(_) do
    api_user = fixture(:api_user)
    {:ok, api_user: api_user}
  end
end
