defmodule Proxy.NotificationsTest do
  use Proxy.DataCase

  alias Proxy.Notifications

  describe "tbl_email_notification_logs" do
    alias Proxy.Notifications.Email

    @valid_attrs %{bank_code: "some bank_code", email: "some email"}
    @update_attrs %{bank_code: "some updated bank_code", email: "some updated email"}
    @invalid_attrs %{bank_code: nil, email: nil}

    def email_fixture(attrs \\ %{}) do
      {:ok, email} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_email()

      email
    end

    test "list_tbl_email_notification_logs/0 returns all tbl_email_notification_logs" do
      email = email_fixture()
      assert Notifications.list_tbl_email_notification_logs() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Notifications.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      assert {:ok, %Email{} = email} = Notifications.create_email(@valid_attrs)
      assert email.bank_code == "some bank_code"
      assert email.email == "some email"
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      assert {:ok, %Email{} = email} = Notifications.update_email(email, @update_attrs)
      assert email.bank_code == "some updated bank_code"
      assert email.email == "some updated email"
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_email(email, @invalid_attrs)
      assert email == Notifications.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Notifications.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Notifications.change_email(email)
    end
  end

  describe "tbl_email_notification_logs" do
    alias Proxy.Notifications.Email

    @valid_attrs %{bank_code: "some bank_code", email: "some email", user_id: "some user_id"}
    @update_attrs %{bank_code: "some updated bank_code", email: "some updated email", user_id: "some updated user_id"}
    @invalid_attrs %{bank_code: nil, email: nil, user_id: nil}

    def email_fixture(attrs \\ %{}) do
      {:ok, email} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_email()

      email
    end

    test "list_tbl_email_notification_logs/0 returns all tbl_email_notification_logs" do
      email = email_fixture()
      assert Notifications.list_tbl_email_notification_logs() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Notifications.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      assert {:ok, %Email{} = email} = Notifications.create_email(@valid_attrs)
      assert email.bank_code == "some bank_code"
      assert email.email == "some email"
      assert email.user_id == "some user_id"
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      assert {:ok, %Email{} = email} = Notifications.update_email(email, @update_attrs)
      assert email.bank_code == "some updated bank_code"
      assert email.email == "some updated email"
      assert email.user_id == "some updated user_id"
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_email(email, @invalid_attrs)
      assert email == Notifications.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Notifications.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Notifications.change_email(email)
    end
  end
end
