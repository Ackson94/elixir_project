defmodule Proxy.Transactions.Archive do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "tbl_archive" do
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
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

end




# defmodule ProxyWeb.ApiController do
#   use ProxyWeb, :controller

#   alias Proxy.Accounts
#   alias Proxy.Workers.BankIntegration
#   alias Proxy.Transactions
#   alias Proxy.Workers.Xml


#   @client_err_codes [400, 401, 402, 403, 404, 409]
#   @server_err_codes [500, 502, 503,]
#   @internal_server_error %{"errorCode"=> "500.0005", "errorMessage"=> "unexpected error"}
#   @authorisation_error %{"errorCode"=> "401", "errorMessage"=> "Authorisation error"}
#   @invalid_payload %{"errorCode"=> "","errorMessage"=> "Invalid payload"}


#   def transfer_request(conn, _params) do
#     request = get_request(conn)
#     case authenticate(request) do
#       {:ok, mno} ->
#         case parameters_valid?(Map.put(request, :amount, to_float(request.amount))) do
#           true->
#             case transfer_funds(request, mno) do
#               {:ok, status_code, response}->
#                 send_response(conn, status_code, request, response, "SUCCESS")
#               {:error, status_code, response}->
#                 send_response(conn, status_code, request, response, "FAIL")
#             end
#           false->
#             send_response(conn, 400, request, @invalid_payload, "FAIL")
#         end
#       {:error, _msg}->
#         send_response(conn, 401, request, @authorisation_error, "FAIL")
#     end
#     # rescue
#     #   _ ->
#     #     conn
#     #     |> put_resp_content_type("application/xml")
#     #     |> send_resp(400, "")
#   end

#   def status_request(conn, _param) do
#     request = get_enquiry_request(conn)
#     case Transactions.get_transfer_by_ext_id(request.externalId) do
#       nil ->
#         conn
#         |>send_response(request, %{status_descript: "transaction does not exist", status_code: "300"})
#       transaction ->
#         conn
#         |>send_response(request, %{status_descript: transaction.status_descript, status_code: transaction.status_code})
#     end
#     rescue
#       _ ->
#         conn
#         |> put_resp_content_type("application/xml")
#         |> send_resp(400, "")
#   end

#   defp get_request(conn) do
#     {_ok, xml_request, _conn} = conn.private[:my_app_body]
#     parsed_request=Xml.parse_soap(xml_request)
#     request_map = for {k, v} <- parsed_request, into: Map.new() do
#       {k, List.to_string(v)}
#     end
#     Map.put(request_map, :request, Poison.encode!(xml_request))
#   end

#   defp get_enquiry_request(conn) do
#     {_ok, body, _conn} = conn.private[:my_app_body]
#     body = Xml.parse_enquiry(body)
#     for {k, v} <- body, into: Map.new() do
#       {k, List.to_string(v)}
#     end
#   end

#   defp authenticate(request) do
#     case Accounts.get_mno_by_username(request.username) do
#       {:error, _error} ->
#         {:error, "Authentication Error"}
#       {:ok, mno} ->
#         case mno.password == request.password do
#           true ->
#             {:ok, mno}
#           false ->
#             {:error, "authentication error"}
#         end
#     end
#   end

#   defp send_response(conn, request, transaction) do
#     conn
#     |> put_resp_content_type("application/xml")
#     |> send_resp(200, Xml.confirm(request, transaction))
#   end

#   defp send_response(conn, response_code, request, response, txn_status_code) do
#     conn
#     |> put_resp_content_type("application/xml")
#     |> send_resp(response_code, Xml.create_response(request, response, txn_status_code))
#   end



#   #======================== TRANSFER ===============================================
#   def transfer_funds(request, mno) do
#     transfer_params = prepare_transfer_params(request, mno)
#     with {:error, _failed_value} <- log_request(request, transfer_params) do
#       {:error, 500, @internal_server_error}
#     else
#       {:ok, logged_request}->
#         case BankIntegration.transfer(transfer_params) do
#           {:ok, response} ->
#             cond do
#               response.status_code == 200->
#                 log_response(response.body, logged_request)
#                 {:ok, 200, Poison.decode!(response.body)}
#               response.status_code in @client_err_codes ->
#                 log_response(response.body, logged_request)
#                 {:error, 400, Poison.decode!(response.body)}
#               response.status_code in @server_err_codes ->
#                 log_response(response.body, logged_request)
#                 {:error, 500, Poison.decode!(response.body)}
#               true->
#                 log_response(Poison.encode!(@internal_server_error), logged_request)
#                 {:error, 500, @internal_server_error}
#             end
#           {:error, _error} ->
#             log_response(Poison.encode!(@internal_server_error), logged_request)
#             {:error, 500, @internal_server_error}
#         end
#     end
#   end


#   #------------------------------ transfer helper methods ----------------------------
#   defp prepare_transfer_params(request, mno) do
#     %{
#       externalId: request.externalId,
#       beneficiaryAccountNumber: request.accountNumber,
#       amount: to_string(request.amount),
#       senderMobileNumber: request.senderMobileNumber,
#       currency:  request.currency,
#       vendorCode: mno.vendor_code,
#       provider: mno.provider,
#       channelCode: mno.channel_code,
#       transmissionDateTime: DateTime.to_iso8601(Timex.local)|> to_string
#     }
#   end

#   defp log_request(request, transfer_params) do
#     transfer = map_to_transfer_tbl(transfer_params)
#     cb_request = Poison.encode!(transfer_params)
#     Transactions.create_transfer(Map.put(transfer, "request", request.request))
#   end

#   defp log_response(response, logged_transfer) do
#     response = Poison.decode!(response)
#     case Map.has_key?(response, "errorCode") do
#       false->
#         %{"balance"=> balance, "voucherNumber"=> vouch_num} = response
#         Transactions.update_transfer(
#           logged_transfer,
#           %{
#             balance: to_string(balance),
#             status_code: "200",
#             voucher_num: vouch_num,
#             status_descript: "success",
#             response: Poison.encode!(response)
#           }
#         )
#       true->
#         %{"errorCode"=> err_code, "errorMessage"=> err_msg} = response
#         Transactions.update_transfer(
#           logged_transfer,
#           %{status_code: err_code, status_descript: err_msg, response: Poison.encode!(response)}
#         )
#     end
#   end

#   def parameters_valid?(payload) do
#     payload_struct= %{
#       :externalId => :string,
#       :amount => :float,
#       :accountNumber => :string,
#       :senderMobileNumber => :string,
#       :referenceNumber => [:string, :not_required],
#       :narrative => [:string, :not_required]
#     }
#     case Skooma.valid?(payload, payload_struct) do
#       :ok -> true
#       {:error, _error_list} -> false
#     end
#   end

#   defp map_to_transfer_tbl(cb_params) do
#     map = %{
#       externalId: "external_id",
#       accountNumber: "acc_num",
#       beneficiaryAccountNumber: "acc_num",
#       amount: "amount",
#       currency: "currency",
#       transmissionDateTime: "transmission_dt_time",
#       vendorCode: "vendor_code",
#       provider: "provider",
#       channelCode: "channel_code",
#       channelDetails: "channel_dtls",
#       referenceNumber: "ref_num",
#       senderMobileNumber: "mobile_num",
#       narrative: "narrative",
#       voucherNumber: "voucher_num",
#       balance: "balance"
#     }
#     for {cb, db} <- map, Map.has_key?(cb_params, cb), into: Map.new() do
#       %{^cb => value}= cb_params
#       {db, value}
#     end
#   end

#   defp to_float(amount) do
#     {float, _rem} = Float.parse(amount)
#     float
#   end

#   #------------------------------ CORE BANKING SIMULATOR ----------------------------
#   def cb_login(conn, _params) do
#     conn = put_status(conn, 200)
#    # json(conn, %{"errorCode" => "401.98", "errorMessage" => "the The specified beneficary account is invalid"})
#    json(conn, %{"token" => "yourtoken", "expiration date" => "12-12-2017"})
#   end

#   def cb_transfer(conn, params) do
#     # %{"amount"=> amount, "beneficiaryAccountNumber"=> acc} = params
#       conn = put_status(conn, 401)
#       json(conn, %{"errorCode" => "403.11", "errorMessage" => " payload is incorrect"})
#     # json(conn, %{"amount" => amount, "balance" => to_float(amount)+400.00, "currency" => "ZMW", "beneficiaryAccountNumber"=> acc, "voucherNumber"=> "00MQ00884590"})
#   end
# end
