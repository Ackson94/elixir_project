defmodule Proxy.Accounts.Mno do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_mnos" do
    field :access_token, :string
    field :bank_password, :string
    field :bank_username, :string
    field :password, :string
    field :username, :string
    field :vendor_code, :string
    field :provider, :string
    field :channel_code, :string
    field :channel_details, :string

    belongs_to :user, Proxy.Accounts.User, foreign_key: :user_id, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mno, attrs) do
    mno
    |> cast(attrs, [:username, :password, :access_token, :bank_username, :bank_password, :vendor_code, :provider, :channel_code, :channel_details, :user_id])
    |> validate_required([:username, :password, :access_token, :vendor_code, :provider, :channel_code])
    |> unique_constraint(:username, name: :unique_username_index)
    |> validate_length(:username, min: 2, max: 15, message: " should be atleast 4 to 15 character(s)")
    |> validate_length(:password,
      min: 4,
      max: 20,
      message: " should be atleast 4 to 20 characters"
    )
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    Ecto.Changeset.put_change(changeset, :password, encrypt_password(password))
  end

  defp put_pass_hash(changeset), do: changeset

  def encrypt_password(password) do
    Base.encode16(:crypto.hash(:sha512, password))
  end
end
