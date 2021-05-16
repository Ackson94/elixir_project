defmodule Proxy.TransactionsTest do
  use Proxy.DataCase

  alias Proxy.Transactions

  describe "tbl_request" do
    alias Proxy.Transactions.Request

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def request_fixture(attrs \\ %{}) do
      {:ok, request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transactions.create_request()

      request
    end

    test "list_tbl_request/0 returns all tbl_request" do
      request = request_fixture()
      assert Transactions.list_tbl_request() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Transactions.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      assert {:ok, %Request{} = request} = Transactions.create_request(@valid_attrs)
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      assert {:ok, %Request{} = request} = Transactions.update_request(request, @update_attrs)
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_request(request, @invalid_attrs)
      assert request == Transactions.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Transactions.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Transactions.change_request(request)
    end
  end

  describe "tbl_request_content" do
    alias Proxy.Transactions.RequestContent

    @valid_attrs %{acc_num: "some acc_num", amount: "some amount", channel_code: "some channel_code", channel_dtls: "some channel_dtls", currency: "some currency", external_id: "some external_id", mobile_num: "some mobile_num", narrative: "some narrative", provider: "some provider", ref_num: "some ref_num", request_id: "some request_id", status: "some status", transmission_dt_time: "some transmission_dt_time", vendor_code: "some vendor_code", voucher_num: "some voucher_num"}
    @update_attrs %{acc_num: "some updated acc_num", amount: "some updated amount", channel_code: "some updated channel_code", channel_dtls: "some updated channel_dtls", currency: "some updated currency", external_id: "some updated external_id", mobile_num: "some updated mobile_num", narrative: "some updated narrative", provider: "some updated provider", ref_num: "some updated ref_num", request_id: "some updated request_id", status: "some updated status", transmission_dt_time: "some updated transmission_dt_time", vendor_code: "some updated vendor_code", voucher_num: "some updated voucher_num"}
    @invalid_attrs %{acc_num: nil, amount: nil, channel_code: nil, channel_dtls: nil, currency: nil, external_id: nil, mobile_num: nil, narrative: nil, provider: nil, ref_num: nil, request_id: nil, status: nil, transmission_dt_time: nil, vendor_code: nil, voucher_num: nil}

    def request_content_fixture(attrs \\ %{}) do
      {:ok, request_content} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transactions.create_request_content()

      request_content
    end

    test "list_tbl_request_content/0 returns all tbl_request_content" do
      request_content = request_content_fixture()
      assert Transactions.list_tbl_request_content() == [request_content]
    end

    test "get_request_content!/1 returns the request_content with given id" do
      request_content = request_content_fixture()
      assert Transactions.get_request_content!(request_content.id) == request_content
    end

    test "create_request_content/1 with valid data creates a request_content" do
      assert {:ok, %RequestContent{} = request_content} = Transactions.create_request_content(@valid_attrs)
      assert request_content.acc_num == "some acc_num"
      assert request_content.amount == "some amount"
      assert request_content.channel_code == "some channel_code"
      assert request_content.channel_dtls == "some channel_dtls"
      assert request_content.currency == "some currency"
      assert request_content.external_id == "some external_id"
      assert request_content.mobile_num == "some mobile_num"
      assert request_content.narrative == "some narrative"
      assert request_content.provider == "some provider"
      assert request_content.ref_num == "some ref_num"
      assert request_content.request_id == "some request_id"
      assert request_content.status == "some status"
      assert request_content.transmission_dt_time == "some transmission_dt_time"
      assert request_content.vendor_code == "some vendor_code"
      assert request_content.voucher_num == "some voucher_num"
    end

    test "create_request_content/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_request_content(@invalid_attrs)
    end

    test "update_request_content/2 with valid data updates the request_content" do
      request_content = request_content_fixture()
      assert {:ok, %RequestContent{} = request_content} = Transactions.update_request_content(request_content, @update_attrs)
      assert request_content.acc_num == "some updated acc_num"
      assert request_content.amount == "some updated amount"
      assert request_content.channel_code == "some updated channel_code"
      assert request_content.channel_dtls == "some updated channel_dtls"
      assert request_content.currency == "some updated currency"
      assert request_content.external_id == "some updated external_id"
      assert request_content.mobile_num == "some updated mobile_num"
      assert request_content.narrative == "some updated narrative"
      assert request_content.provider == "some updated provider"
      assert request_content.ref_num == "some updated ref_num"
      assert request_content.request_id == "some updated request_id"
      assert request_content.status == "some updated status"
      assert request_content.transmission_dt_time == "some updated transmission_dt_time"
      assert request_content.vendor_code == "some updated vendor_code"
      assert request_content.voucher_num == "some updated voucher_num"
    end

    test "update_request_content/2 with invalid data returns error changeset" do
      request_content = request_content_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_request_content(request_content, @invalid_attrs)
      assert request_content == Transactions.get_request_content!(request_content.id)
    end

    test "delete_request_content/1 deletes the request_content" do
      request_content = request_content_fixture()
      assert {:ok, %RequestContent{}} = Transactions.delete_request_content(request_content)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_request_content!(request_content.id) end
    end

    test "change_request_content/1 returns a request_content changeset" do
      request_content = request_content_fixture()
      assert %Ecto.Changeset{} = Transactions.change_request_content(request_content)
    end
  end
end
