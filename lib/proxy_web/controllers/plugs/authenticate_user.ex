defmodule ProxyWeb.Plugs.AuthenticateUser do
  import Plug.Conn
  alias ProxyWeb.MnoController, as: Mno
  alias Proxy.Auth

  def authenticate(conn, username, password) do
    case Mno.get_by_username(username) do
      {:ok, user} ->
        case Auth.confirm_password(user, password) do
          {:ok, _} -> conn
          {:error, _} -> halt(conn)
        end

      {:error, _reason} ->
        halt(conn)
    end
  end

  def unauthorized_response(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"message": "Authentication Failed"}])
  end
end
