defmodule ProxyWeb.RequestContentControllerTest do
  use ProxyWeb.ConnCase

  alias Proxy.Transactions

  @create_attrs %{acc_num: "some acc_num", amount: "some amount", channel_code: "some channel_code", channel_dtls: "some channel_dtls", currency: "some currency", external_id: "some external_id", mobile_num: "some mobile_num", narrative: "some narrative", provider: "some provider", ref_num: "some ref_num", request_id: "some request_id", status: "some status", transmission_dt_time: "some transmission_dt_time", vendor_code: "some vendor_code", voucher_num: "some voucher_num"}
  @update_attrs %{acc_num: "some updated acc_num", amount: "some updated amount", channel_code: "some updated channel_code", channel_dtls: "some updated channel_dtls", currency: "some updated currency", external_id: "some updated external_id", mobile_num: "some updated mobile_num", narrative: "some updated narrative", provider: "some updated provider", ref_num: "some updated ref_num", request_id: "some updated request_id", status: "some updated status", transmission_dt_time: "some updated transmission_dt_time", vendor_code: "some updated vendor_code", voucher_num: "some updated voucher_num"}
  @invalid_attrs %{acc_num: nil, amount: nil, channel_code: nil, channel_dtls: nil, currency: nil, external_id: nil, mobile_num: nil, narrative: nil, provider: nil, ref_num: nil, request_id: nil, status: nil, transmission_dt_time: nil, vendor_code: nil, voucher_num: nil}

  def fixture(:request_content) do
    {:ok, request_content} = Transactions.create_request_content(@create_attrs)
    request_content
  end

  describe "index" do
    test "lists all tbl_request_content", %{conn: conn} do
      conn = get(conn, Routes.request_content_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl request content"
    end
  end

  describe "new request_content" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.request_content_path(conn, :new))
      assert html_response(conn, 200) =~ "New Request content"
    end
  end

  describe "create request_content" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.request_content_path(conn, :create), request_content: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.request_content_path(conn, :show, id)

      conn = get(conn, Routes.request_content_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Request content"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.request_content_path(conn, :create), request_content: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Request content"
    end
  end

  describe "edit request_content" do
    setup [:create_request_content]

    test "renders form for editing chosen request_content", %{conn: conn, request_content: request_content} do
      conn = get(conn, Routes.request_content_path(conn, :edit, request_content))
      assert html_response(conn, 200) =~ "Edit Request content"
    end
  end

  describe "update request_content" do
    setup [:create_request_content]

    test "redirects when data is valid", %{conn: conn, request_content: request_content} do
      conn = put(conn, Routes.request_content_path(conn, :update, request_content), request_content: @update_attrs)
      assert redirected_to(conn) == Routes.request_content_path(conn, :show, request_content)

      conn = get(conn, Routes.request_content_path(conn, :show, request_content))
      assert html_response(conn, 200) =~ "some updated acc_num"
    end

    test "renders errors when data is invalid", %{conn: conn, request_content: request_content} do
      conn = put(conn, Routes.request_content_path(conn, :update, request_content), request_content: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Request content"
    end
  end

  describe "delete request_content" do
    setup [:create_request_content]

    test "deletes chosen request_content", %{conn: conn, request_content: request_content} do
      conn = delete(conn, Routes.request_content_path(conn, :delete, request_content))
      assert redirected_to(conn) == Routes.request_content_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.request_content_path(conn, :show, request_content))
      end
    end
  end

  defp create_request_content(_) do
    request_content = fixture(:request_content)
    {:ok, request_content: request_content}
  end
end
