defmodule ProxyWeb.ApiController do
  use ProxyWeb, :controller

  alias Proxy.Auth
  alias Proxy.Accounts
  alias Proxy.Workers.BankIntegration
  alias Proxy.Transactions
  alias Proxy.Workers.Xml


  @client_err_codes [400, 401, 402, 403, 404, 409]
  @server_err_codes [500, 502, 503,]
  @internal_server_error %{"errorCode"=> "500.0005", "errorMessage"=> "unexpected error"}
  @authorisation_error %{"errorCode"=> "401", "errorMessage"=> "Authorisation error"}
  @invalid_payload %{"errorCode"=> "", "errorMessage"=> "Invalid payload"}


  def transfer_request(conn, %{"username"=>username, "password"=>password}) do
    request = get_request(conn)
    case authenticate(username, password) do
      {:ok, mno} ->
        case parameters_valid?(Map.put(request, :amount, to_float(request.amount))) do
          true->
            case transfer_funds(request, mno) do
              {:ok, status_code, response}->
                send_response(conn, status_code, request, response, "SUCCESS")
              {:error, status_code, response}->
                send_response(conn, status_code, request, response, "FAIL")
            end
          false->
            send_response(conn, 400, request, @invalid_payload, "FAIL")
        end
      {:error, _msg}->
        send_response(conn, 401, request, @authorisation_error, "FAIL")
    end
    # rescue
    #   _ ->
    #     conn
    #     |> put_resp_content_type("application/xml")
    #     |> send_resp(400, "")
  end

  def status_request(conn, _param) do
    request = get_enquiry_request(conn)
    case Transactions.get_transfer_by_ext_id(request.externalId) do
      nil ->
        conn
        |>send_response(request, %{status_descript: "transaction does not exist", status_code: "300"})
      transaction ->
        conn
        |>send_response(request, %{status_descript: transaction.status_descript, status_code: transaction.status_code})
    end
    rescue
      _ ->
        conn
        |> put_resp_content_type("application/xml")
        |> send_resp(400, "")
  end

  defp get_request(conn) do
    {_ok, xml_request, _conn} = conn.private[:my_app_body]
    parsed_request=Xml.parse_soap(xml_request)
    request_map = for {k, v} <- parsed_request, into: Map.new() do
      {k, List.to_string(v)}
    end
    Map.put(request_map, :request, Poison.encode!(xml_request))
  end

  defp get_enquiry_request(conn) do
    {_ok, body, _conn} = conn.private[:my_app_body]
    body = Xml.parse_enquiry(body)
    for {k, v} <- body, into: Map.new() do
      {k, List.to_string(v)}
    end
  end



  # def authenticate(username, password) do
  #   case Accounts.get_mno_by_username(username) do
  #     {:error, _error} ->
  #       {:error, "Authentication Error"}
  #     {:ok, mno} ->
  #       case Auth.confirm_password(mno, String.trim(password)) do
  #         {:ok, _reason} ->
  #           {:ok, mno}
  #         {:error, _reason} ->
  #           {:error, "authentication error"}
  #       end
  #   end
  # end

  defp authenticate(username, password) do
    case Accounts.get_mno_by_username(username) do
      {:error, _error} ->
        {:error, "Authentication Error"}
      {:ok, mno} ->
        case mno.password == password do
          true ->
            {:ok, mno}
          false ->
            {:error, "authentication error"}
        end
    end
  end


  defp log_failed_request(mno, request, response) do
    prepare_transfer_params(request, mno)
    |> map_to_transfer_tbl()
    |> Map.merge(
      %{
        "status_code"=> "300",
        "request"=> request.request,
        "status_descript"=> response["errorMessage"],
        "response"=> Xml.create_response(request, response, "FAIL"),
      })
    |> Transactions.create_transfer()
  end

  defp send_response(conn, request, transaction) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, Xml.confirm(request, transaction))
  end

  defp send_response(conn, response_code, request, response, txn_status_code) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(response_code, Xml.create_response(request, response, txn_status_code))
  end



  #======================== TRANSFER ===============================================
  def transfer_funds(request, mno) do
    transfer_params = prepare_transfer_params(request, mno)
    with {:error, _failed_value} <- log_request(request, transfer_params) do
      {:error, 500, @internal_server_error}
    else
      {:ok, logged_request}->
        case BankIntegration.transfer(transfer_params) do
          {:ok, response} ->
            cond do
              response.status_code == 200->
                proxy_resp = Xml.create_response(request, Poison.decode!(response.body), "SUCCESS")
                log_response(response.body, logged_request, proxy_resp)
                {:ok, 200, Poison.decode!(response.body)}
              response.status_code in @client_err_codes ->
                proxy_resp = Xml.create_response(request, Poison.decode!(response.body), "FAIL")
                log_response(response.body, logged_request, proxy_resp)
                {:error, 400, Poison.decode!(response.body)}
              response.status_code in @server_err_codes ->
                proxy_resp = Xml.create_response(request, Poison.decode!(response.body), "FAIL")
                log_response(response.body, logged_request, proxy_resp)
                {:error, 500, Poison.decode!(response.body)}
              true->
                proxy_resp = Xml.create_response(request, @internal_server_error, "FAIL")
                log_response(Poison.encode!(@internal_server_error), logged_request, proxy_resp)
                {:error, 500, @internal_server_error}
            end
          {:error, %HTTPoison.Error{reason: reason}} ->
            resp = %{"errorCode"=> "500.0004", "errorMessage"=> to_string(reason)}
            proxy_resp = Xml.create_response(request, resp, "FAIL")
            log_response(Poison.encode!(resp), logged_request, proxy_resp)
            {:error, 500, resp}
        end
    end
  end


  #------------------------------ transfer helper methods ----------------------------
  defp prepare_transfer_params(request, mno) do
    %{
      externalId: request.externalId,
      beneficiaryAccountNumber: request.accountNumber,
      amount: to_string(request.amount),
      senderMobileNumber: request.senderMobileNumber,
      currency: request.currency,
      referenceNumber: gen_ref(request),
      vendorCode: mno.vendor_code,
      provider: mno.provider,
      channelCode: mno.channel_code,
      transmissionDateTime: DateTime.to_iso8601(Timex.local)|> to_string|>String.slice( 0..22)
    }
  end

  defp gen_ref(request) do
    date=Timex.today|>to_string|>String.replace("-", "")|>String.slice( 4..7)
    mobile= String.slice(request.senderMobileNumber, -3..-1)
    random = to_string(Enum.random(100000..999999))
    date<>mobile<>random
  end

  defp log_request(request, transfer_params) do
    map_to_transfer_tbl(transfer_params)
    |> Map.merge(
      %{
        "status_code"=> "100",
        "status_descript"=> "forwarded to cb",
        "request"=> request.request,
        "cb_request"=> Poison.encode!(transfer_params)
        })
    |> Transactions.create_transfer()
  end

  defp log_response(response, logged_transfer, proxy_resp) do
      Task.Supervisor.start_child(
        Proxy.TaskSupervisor,
        fn ->
          log_the_response(response, logged_transfer, proxy_resp)
        end
      )
  end

  defp log_the_response(response, logged_transfer, proxy_resp) do
    response = Poison.decode!(response)
    case Map.has_key?(response, "errorCode") do
      false->
        %{"balance"=> balance, "voucherNumber"=> vouch_num} = response
        Transactions.update_transfer(
          logged_transfer,
          %{
            balance: to_string(balance),
            status_code: "200",
            voucher_num: vouch_num,
            status_descript: "success",
            cb_response: Poison.encode!(response),
            response: proxy_resp
          }
        )
      true->
        %{"errorCode"=> err_code, "errorMessage"=> err_msg} = response
        Transactions.update_transfer(
          logged_transfer,
          %{
            status_code: err_code,
            status_descript: err_msg,
            cb_response: Poison.encode!(response),
            response: proxy_resp
          }
        )
    end
  end

  def parameters_valid?(payload) do
    payload_struct= %{
      :externalId => :string,
      :amount => :float,
      :accountNumber => :string,
      :senderMobileNumber => :string,
      :referenceNumber => [:string, :not_required],
      :narrative => [:string, :not_required]
    }
    case Skooma.valid?(payload, payload_struct) do
      :ok -> true
      {:error, _error_list} -> false
    end
  end

  defp map_to_transfer_tbl(cb_params) do
    map = %{
      externalId: "external_id",
      accountNumber: "acc_num",
      beneficiaryAccountNumber: "acc_num",
      amount: "amount",
      currency: "currency",
      transmissionDateTime: "transmission_dt_time",
      vendorCode: "vendor_code",
      provider: "provider",
      channelCode: "channel_code",
      channelDetails: "channel_dtls",
      referenceNumber: "ref_num",
      senderMobileNumber: "mobile_num",
      narrative: "narrative",
      voucherNumber: "voucher_num",
      balance: "balance"
    }
    for {cb, db} <- map, Map.has_key?(cb_params, cb), into: Map.new() do
      %{^cb => value}= cb_params
      {db, value}
    end
  end

  defp to_float(amount) do
    {float, _rem} = Float.parse(amount)
    float
  end

  #------------------------------ CORE BANKING SIMULATOR ----------------------------
  def cb_login(conn, _params) do
    # conn = put_status(conn, 200)
   json(conn, %{"errorCode" => "401.98", "errorMessage" => "the The specified beneficary account is invalid"})
  #  json(conn, %{"token" => "yourtoken", "expiration date" => "12-12-2017"})
  end

  def cb_transfer(conn, params) do
    # %{"amount"=> amount, "beneficiaryAccountNumber"=> acc} = params
      conn = put_status(conn, 202)
      json(conn, %{"errorCode" => "403.11", "errorMessage" => " payload is incorrect"})
    # json(conn, %{"amount" => amount, "balance" => to_float(amount)+400.00, "currency" => "ZMW", "beneficiaryAccountNumber"=> acc, "voucherNumber"=> "00MQ00884590"})
  end

  #proxy user Admin, password= password123
  #mno Airtel, password= password01

  #========test
  def login(conn, _params) do
    
    json(conn, %{token: "Ackson", expiration: "2021-04-27T10:17:17Z"})
  end

  def customer(conn, %{"mobilenumber" => number}) do
    IO.inspect "((((((())"
    IO.inspect number
    IO.inspect "((((((())"
    json(conn, %{
      customerNumber: number,
      mobileBankingCustomerStatus: "Active",
      mobileBankingPhoneNumber: "8789798778",
      mobileRegistrationStatusL: 1
    })
  end

  def look(conn, _params) do

    json(conn,
      %{
        externalId: "412512",
        accountNumber: "0124100000141",
        transmissionDateTime: "2019-05-30T13:29:12.456Z",
        referenceNumber: "dsgdgasds",
        senderMobileNumber: "260965335577",
        vendorCode: "MTN",
        channelCode: "MOB",
        isRepetition: true
      }
    )
    
  end

  def hold(conn, _params) do
    json(conn, 
    %{
      externalId: "412512",
      amount: 123.40,
      currency: "ZMK",
      beneficiaryAccountNumber: "0724200005255",
      transmissionDateTime: "2019-05-30T13:29:12.456Z",
      referenceNumber: "dsgdgasds",
      senderMobileNumber: "260965335577",
      vendorCode: "MTN",
      provider: "nSano",
      channelCode: "MOB",
      channelDetails: "xcgdsfgsd ifw088",
      narrative: "Test eWallet MBS transfer to repay loan"
    }
    )
  end


  def message(conn, %{"accountNumber" => customerNumber}) do

    IO.inspect "(((((((())))))"
    IO.inspect customerNumber
    IO.inspect "(((((((())))))"

    json(conn,
    %{
        messageId: "1",
        uid: "1",
        customerNumber: "0018901001",
        customerName: "Ackson",
       mobileBankingPhoneNumber: "67767776",
       accounts: [
         
           accountNumber: "000000000000077",
           internalAccountNumber: "43",
           productType: "123",
           status: "PENDING",
           openingDate: "2021-05-05",
           balance: 0,
           currency: "ZMS",
           subProductName: "product",
           minimumBalance: 0,
           retainedAmount: 0,
           accountHolderRelation: "686876868",
           isLinkedToLoan: true,
           isLinkedToTDA: true,
           payableInterest: 0,
           overdraftInterest: 0,
           isMobileBankingActive: true
       ]
      
   
    })
  end


end
