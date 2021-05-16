defmodule Proxy.Activity.UserLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_user_activity" do
    field :activity, :string  

    belongs_to :user, Proxy.Accounts.User, foreign_key: :user_id, type: :id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_log, attrs) do
    user_log
    |> cast(attrs, [:activity, :user_id])
    |> validate_required([:activity, :user_id])
  end
end
