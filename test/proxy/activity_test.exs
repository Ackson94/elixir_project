defmodule Proxy.ActivityTest do
  use Proxy.DataCase

  alias Proxy.Activity

  describe "tbl_user_activity" do
    alias Proxy.Activity.UserLog

    @valid_attrs %{activity: "some activity"}
    @update_attrs %{activity: "some updated activity"}
    @invalid_attrs %{activity: nil}

    def user_log_fixture(attrs \\ %{}) do
      {:ok, user_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Activity.create_user_log()

      user_log
    end

    test "list_tbl_user_activity/0 returns all tbl_user_activity" do
      user_log = user_log_fixture()
      assert Activity.list_tbl_user_activity() == [user_log]
    end

    test "get_user_log!/1 returns the user_log with given id" do
      user_log = user_log_fixture()
      assert Activity.get_user_log!(user_log.id) == user_log
    end

    test "create_user_log/1 with valid data creates a user_log" do
      assert {:ok, %UserLog{} = user_log} = Activity.create_user_log(@valid_attrs)
      assert user_log.activity == "some activity"
    end

    test "create_user_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activity.create_user_log(@invalid_attrs)
    end

    test "update_user_log/2 with valid data updates the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{} = user_log} = Activity.update_user_log(user_log, @update_attrs)
      assert user_log.activity == "some updated activity"
    end

    test "update_user_log/2 with invalid data returns error changeset" do
      user_log = user_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Activity.update_user_log(user_log, @invalid_attrs)
      assert user_log == Activity.get_user_log!(user_log.id)
    end

    test "delete_user_log/1 deletes the user_log" do
      user_log = user_log_fixture()
      assert {:ok, %UserLog{}} = Activity.delete_user_log(user_log)
      assert_raise Ecto.NoResultsError, fn -> Activity.get_user_log!(user_log.id) end
    end

    test "change_user_log/1 returns a user_log changeset" do
      user_log = user_log_fixture()
      assert %Ecto.Changeset{} = Activity.change_user_log(user_log)
    end
  end
end
