defmodule Proxy.Settings.Sms do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_sms_config" do
    field :password, :string
    field :sender_id, :string
    field :url, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(sms, attrs) do
    sms
    |> cast(attrs, [:username, :password, :sender_id, :url])
    |> validate_required([:username, :password, :sender_id, :url])
  end
end
