defmodule Proxy.AccountsTest do
  use Proxy.DataCase

  alias Proxy.Accounts

  describe "users" do
    alias Proxy.Accounts.User

    @valid_attrs %{bank_password: "some bank_password", bank_username: "some bank_username", password: "some password", username: "some username"}
    @update_attrs %{bank_password: "some updated bank_password", bank_username: "some updated bank_username", password: "some updated password", username: "some updated username"}
    @invalid_attrs %{bank_password: nil, bank_username: nil, password: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.bank_password == "some bank_password"
      assert user.bank_username == "some bank_username"
      assert user.password == "some password"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.bank_password == "some updated bank_password"
      assert user.bank_username == "some updated bank_username"
      assert user.password == "some updated password"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "tbl_api_users" do
    alias Proxy.Accounts.ApiUser

    @valid_attrs %{access_token: "some access_token", bank_password: "some bank_password", bank_username: "some bank_username", password: "some password", username: "some username", vendor_code: "some vendor_code"}
    @update_attrs %{access_token: "some updated access_token", bank_password: "some updated bank_password", bank_username: "some updated bank_username", password: "some updated password", username: "some updated username", vendor_code: "some updated vendor_code"}
    @invalid_attrs %{access_token: nil, bank_password: nil, bank_username: nil, password: nil, username: nil, vendor_code: nil}

    def api_user_fixture(attrs \\ %{}) do
      {:ok, api_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_api_user()

      api_user
    end

    test "list_tbl_api_users/0 returns all tbl_api_users" do
      api_user = api_user_fixture()
      assert Accounts.list_tbl_api_users() == [api_user]
    end

    test "get_api_user!/1 returns the api_user with given id" do
      api_user = api_user_fixture()
      assert Accounts.get_api_user!(api_user.id) == api_user
    end

    test "create_api_user/1 with valid data creates a api_user" do
      assert {:ok, %ApiUser{} = api_user} = Accounts.create_api_user(@valid_attrs)
      assert api_user.access_token == "some access_token"
      assert api_user.bank_password == "some bank_password"
      assert api_user.bank_username == "some bank_username"
      assert api_user.password == "some password"
      assert api_user.username == "some username"
      assert api_user.vendor_code == "some vendor_code"
    end

    test "create_api_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_api_user(@invalid_attrs)
    end

    test "update_api_user/2 with valid data updates the api_user" do
      api_user = api_user_fixture()
      assert {:ok, %ApiUser{} = api_user} = Accounts.update_api_user(api_user, @update_attrs)
      assert api_user.access_token == "some updated access_token"
      assert api_user.bank_password == "some updated bank_password"
      assert api_user.bank_username == "some updated bank_username"
      assert api_user.password == "some updated password"
      assert api_user.username == "some updated username"
      assert api_user.vendor_code == "some updated vendor_code"
    end

    test "update_api_user/2 with invalid data returns error changeset" do
      api_user = api_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_api_user(api_user, @invalid_attrs)
      assert api_user == Accounts.get_api_user!(api_user.id)
    end

    test "delete_api_user/1 deletes the api_user" do
      api_user = api_user_fixture()
      assert {:ok, %ApiUser{}} = Accounts.delete_api_user(api_user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_api_user!(api_user.id) end
    end

    test "change_api_user/1 returns a api_user changeset" do
      api_user = api_user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_api_user(api_user)
    end
  end
end
