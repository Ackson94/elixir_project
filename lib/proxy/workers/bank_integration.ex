defmodule Proxy.Workers.BankIntegration do
  alias Proxy.Settings

  def login do
     cb_config = Settings.cb_configs()

     case cb_config do
        nil -> {:error, "No Core Banking Configurations Found"}
        cb_config ->
           auth = String.trim(cb_config.username)<>":"<>String.trim(cb_config.password)|> Base.encode64
           request_headers = [{"Authorization", "Basic "<>auth}, {"Content-Type", "application/json"}]
           options = [hackney: [:insecure], timeout: 50_000, recv_timeout: 60_000]
           HTTPoison.get(String.trim(cb_config.login_url), request_headers, options)
     end
   end

  # def login do
  #    cb_config = Settings.cb_configs()

  #    request_headers = [{"Authorization", "Basic #{"Probase:Test1234"|> Base.encode64}"}, {"Content-Type", "application/json"}]
  #    options = [hackney: [:insecure], timeout: 50_000, recv_timeout: 60_000]
  #    # HTTPoison.get("https://172.17.101.120:5000/api/auth/login", request_headers, options)
  #    HTTPoison.get(String.trim(cb_config.login_url), request_headers, options)
  # end


  def transfer(payload) do
    cb_config = Settings.cb_configs()

    token = Cachex.get!(:session, "session_token")
    request_headers = [{"Authorization", "Bearer #{token}"}, {"Content-Type", "application/json"}]
    options = [hackney: [:insecure], timeout: 50_000, recv_timeout: 60_000]
    HTTPoison.post(String.trim(cb_config.fund_transf_url), Poison.encode!(payload), request_headers, options)
  end
end

# https://172.17.101.120:5000/API/Accounts/NameLookup
# https://172.17.101.120:5000/API/Transactions/Transfers/WalletToBank
# https://172.17.101.120:5000/api/auth/login
