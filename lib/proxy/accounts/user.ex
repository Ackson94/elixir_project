defmodule Proxy.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_users" do
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :password, :string
    field :email, :string
    field :user_type, :integer
    field :user_role, :integer
    field :status, :integer, default: 1
    field :auto_password, :string, default: "Y"

    belongs_to :user, Proxy.Accounts.User, foreign_key: :user_id, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :username,
      :password,
      :auto_password,
      :email,
      :user_type,
      :user_role,
      :status,
      :user_id])
    |> validate_required([
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :user_type,
      :status])
      |> unique_constraint(:email, name: :unique_email_tbl_users, message: " address already exists")
      |> unique_constraint(:username, name: :unique_username_tbl_users, message: " already exists")
      |> validate_length(:password,
        min: 4,
        max: 40,
        message: "should be atleast 4 to 40 characters"
      )
      |> validate_length(:username,
        min: 4,
        max: 50,
        message: "should be atleast 4 to 50 characters"
      )
      |> validate_length(:first_name,
        min: 3,
        max: 100,
        message: "should be between 3 to 100 characters"
      )
      |> validate_length(:last_name,
        min: 3,
        max: 100,
        message: "should be between 3 to 100 characters"
      )
      |> validate_length(:email,
        min: 10,
        max: 150,
        message: "should be between 10 to 150 characters"
      )
      |> put_pass_hash()
      |> validate_user_role()
    end

    defp validate_user_role(%Ecto.Changeset{valid?: true, changes: %{user_type: type, user_role: role}} = changeset) do
      case role == 1 && type == 2 do
        true ->
          add_error(changeset, :user, "under operations can't be admin")
        _->
          changeset
      end
    end
    defp validate_user_role(changeset), do: changeset

    defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
      Ecto.Changeset.put_change(changeset, :password, encrypt_password(password))
    end
    defp put_pass_hash(changeset), do: changeset

    def encrypt_password(password), do: Base.encode16(:crypto.hash(:sha512, password))
end

# Proxy.Accounts.create_user(%{first_name: "Ackson", last_name: "Mutuma", email: "acksonic@probasegroup.com", password: "ackson123", user_role: 1, user_type: 1, username: "ackson", status: 1, inserted_at: NaiveDateTime.utc_now, updated_at: NaiveDateTime.utc_now})

