defmodule Proxy.SettingsTest do
  use Proxy.DataCase

  alias Proxy.Settings

  describe "tbl_sms_config" do
    alias Proxy.Settings.Sms

    @valid_attrs %{password: "some password", sender_id: "some sender_id", url: "some url", username: "some username"}
    @update_attrs %{password: "some updated password", sender_id: "some updated sender_id", url: "some updated url", username: "some updated username"}
    @invalid_attrs %{password: nil, sender_id: nil, url: nil, username: nil}

    def sms_fixture(attrs \\ %{}) do
      {:ok, sms} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_sms()

      sms
    end

    test "list_tbl_sms_config/0 returns all tbl_sms_config" do
      sms = sms_fixture()
      assert Settings.list_tbl_sms_config() == [sms]
    end

    test "get_sms!/1 returns the sms with given id" do
      sms = sms_fixture()
      assert Settings.get_sms!(sms.id) == sms
    end

    test "create_sms/1 with valid data creates a sms" do
      assert {:ok, %Sms{} = sms} = Settings.create_sms(@valid_attrs)
      assert sms.password == "some password"
      assert sms.sender_id == "some sender_id"
      assert sms.url == "some url"
      assert sms.username == "some username"
    end

    test "create_sms/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_sms(@invalid_attrs)
    end

    test "update_sms/2 with valid data updates the sms" do
      sms = sms_fixture()
      assert {:ok, %Sms{} = sms} = Settings.update_sms(sms, @update_attrs)
      assert sms.password == "some updated password"
      assert sms.sender_id == "some updated sender_id"
      assert sms.url == "some updated url"
      assert sms.username == "some updated username"
    end

    test "update_sms/2 with invalid data returns error changeset" do
      sms = sms_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_sms(sms, @invalid_attrs)
      assert sms == Settings.get_sms!(sms.id)
    end

    test "delete_sms/1 deletes the sms" do
      sms = sms_fixture()
      assert {:ok, %Sms{}} = Settings.delete_sms(sms)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_sms!(sms.id) end
    end

    test "change_sms/1 returns a sms changeset" do
      sms = sms_fixture()
      assert %Ecto.Changeset{} = Settings.change_sms(sms)
    end
  end

  describe "tbl_cb_config" do
    alias Proxy.Settings.CoreBanking

    @valid_attrs %{fund_transf_url: "some fund_transf_url", login_url: "some login_url", name_lkup_url: "some name_lkup_url", password: "some password", username: "some username"}
    @update_attrs %{fund_transf_url: "some updated fund_transf_url", login_url: "some updated login_url", name_lkup_url: "some updated name_lkup_url", password: "some updated password", username: "some updated username"}
    @invalid_attrs %{fund_transf_url: nil, login_url: nil, name_lkup_url: nil, password: nil, username: nil}

    def core_banking_fixture(attrs \\ %{}) do
      {:ok, core_banking} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_core_banking()

      core_banking
    end

    test "list_tbl_cb_config/0 returns all tbl_cb_config" do
      core_banking = core_banking_fixture()
      assert Settings.list_tbl_cb_config() == [core_banking]
    end

    test "get_core_banking!/1 returns the core_banking with given id" do
      core_banking = core_banking_fixture()
      assert Settings.get_core_banking!(core_banking.id) == core_banking
    end

    test "create_core_banking/1 with valid data creates a core_banking" do
      assert {:ok, %CoreBanking{} = core_banking} = Settings.create_core_banking(@valid_attrs)
      assert core_banking.fund_transf_url == "some fund_transf_url"
      assert core_banking.login_url == "some login_url"
      assert core_banking.name_lkup_url == "some name_lkup_url"
      assert core_banking.password == "some password"
      assert core_banking.username == "some username"
    end

    test "create_core_banking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_core_banking(@invalid_attrs)
    end

    test "update_core_banking/2 with valid data updates the core_banking" do
      core_banking = core_banking_fixture()
      assert {:ok, %CoreBanking{} = core_banking} = Settings.update_core_banking(core_banking, @update_attrs)
      assert core_banking.fund_transf_url == "some updated fund_transf_url"
      assert core_banking.login_url == "some updated login_url"
      assert core_banking.name_lkup_url == "some updated name_lkup_url"
      assert core_banking.password == "some updated password"
      assert core_banking.username == "some updated username"
    end

    test "update_core_banking/2 with invalid data returns error changeset" do
      core_banking = core_banking_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_core_banking(core_banking, @invalid_attrs)
      assert core_banking == Settings.get_core_banking!(core_banking.id)
    end

    test "delete_core_banking/1 deletes the core_banking" do
      core_banking = core_banking_fixture()
      assert {:ok, %CoreBanking{}} = Settings.delete_core_banking(core_banking)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_core_banking!(core_banking.id) end
    end

    test "change_core_banking/1 returns a core_banking changeset" do
      core_banking = core_banking_fixture()
      assert %Ecto.Changeset{} = Settings.change_core_banking(core_banking)
    end
  end
end
