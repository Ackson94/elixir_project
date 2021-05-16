defmodule Proxy.Notifications.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_email_notification_logs" do
    field :bank_code, :string
    field :email, :string

    belongs_to :user, Proxy.Accounts.User, foreign_key: :user_id, type: :id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:branch_code, :email, :user_id])
    |> validate_required([:branch_code, :email])
    |> validate_length(:branch_code,
      min: 3,
      max: 20,
      message: "should be between 3 to 20 characters"
    )
    |> validate_length(:email,
      min: 10,
      max: 150,
      message: "should be between 10 to 150 characters"
    )
    |> unique_constraint(:branch_code,
      name: :tbl_email_notification_logs_branch_code_email_index,
      message: "/email already exists. Please try again with different details"
    )
  end
end
