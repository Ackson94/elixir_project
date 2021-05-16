defmodule Proxy.Repo do
  use Ecto.Repo,
    otp_app: :proxy,
    adapter: Tds.Ecto

  use Scrivener
end
