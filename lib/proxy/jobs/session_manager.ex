defmodule Proxy.Jobs.SessionManager do
  use Task
  alias Proxy.Workers.BankIntegration



  def start_link(_arg) do
    IO.inspect "Authenticating with core banking...."
    fetch_session()
    Task.start_link(&fetch_session/0)
  end

  def fetch_session() do
      BankIntegration.login
      |> case do
        {:ok, response} ->
          cond do
            response.status_code == 200->
              body = Poison.decode!(response.body)
              case Map.has_key?(body, "token") do
                true->
                  %{"token"=> token} = body
                  Cachex.put(:session, "session_token", token)
                  IO.inspect "successfully authenticated with core banking!"
                false->
                  IO.inspect "login failure, check credentials"
              end
            response.status_code == 401 ->
              IO.inspect "core banking login failure, check credentials"
            true ->
              IO.inspect "core banking login failure, unexpected response code recieved"
          end

        {:error, reason}->
          IO.inspect "Failed to authenticate with core banking, reason:"
          IO.inspect reason
      end
  end
end
