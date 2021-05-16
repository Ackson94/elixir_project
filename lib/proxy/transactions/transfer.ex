defmodule Proxy.Transactions.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Proxy.Transactions.Transfer.Localtime, :autogenerate, []}]
  schema "tbl_transfer" do
    field :external_id, :string
    field :acc_num, :string
    field :amount, :decimal
    field :currency, :string
    field :mobile_num, :string
    field :narrative, :string
    field :channel_code, :string
    field :channel_dtls, :string
    field :provider, :string
    field :vendor_code, :string
    field :ref_num, :string
    field :transmission_dt_time, :naive_datetime
    field :voucher_num, :string
    field :balance, :decimal
    field :status_code, :string
    field :status_descript, :string
    field :request, :string
    field :cb_request, :string
    field :cb_response, :string
    field :response, :string

    timestamps()
  end

  @doc false
  def changeset(request_content, attrs) do
    request_content
    |> cast(attrs, [:external_id, :acc_num, :transmission_dt_time, :ref_num, :mobile_num, :vendor_code, :provider, :channel_code, :amount, :currency, :channel_dtls, :narrative, :voucher_num, :status_code, :balance, :status_descript, :request, :response, :cb_request, :cb_response])
    |> validate_required([:external_id, :transmission_dt_time, :vendor_code, :provider, :channel_code, :request, :cb_request])
  end

  defmodule Localtime do
    def autogenerate, do: Timex.local |> DateTime.truncate(:second) |> Ecto.DateTime.cast!
  end
end
