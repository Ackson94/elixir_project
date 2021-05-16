defmodule Proxy.Settings.CoreBanking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_cb_config" do
    field :fund_transf_url, :string
    field :login_url, :string
    field :name_lkup_url, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(core_banking, attrs) do
    core_banking
    |> cast(attrs, [:username, :password, :login_url, :name_lkup_url, :fund_transf_url])
    |> validate_required([:username, :password, :login_url, :fund_transf_url])
  end
end
