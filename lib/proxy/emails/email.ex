defmodule Proxy.Emails.Email do
  import Bamboo.Email
  # alias Bamboo.Attachment
  use Bamboo.Phoenix, view: ProxyWeb.EmailView
  alias Proxy.Emails.Mailer
  # alias Proxy.Notifications


  # def send_email_notification(attr) do
  #   Notifications.list_tbl_email_logs()
  #   |> Task.async_stream(&(email_alert(&1.email, attr) |> Mailer.deliver_now()),
  #     max_concurrency: 10,
  #     timeout: 30_000
  #   )
  #   |> Stream.run()
  # end

  def password_alert(email, password, username) do
    password(email, password, username) |> Mailer.deliver_later()
  end

  def confirm_password_reset(token, email) do
    confirmation_token(token, email) |> Mailer.deliver_later()
  end

  def password(email, password, username) do
    new_email()
    |> from("johnmfula360@gmail.com")
    |> to("#{email}")
    |> put_html_layout({ProxyWeb.LayoutView, "email.html"})
    |> subject("Proxy Password")
    |> assign(:user_credentials, %{password: password, username: username})
    |> render("password_content.html")
  end

  def confirmation_token(token, email) do
    new_email()
    |> from("johnmfula360@gmail.com")
    |> to("#{email}")
    |> put_html_layout({ProxyWeb.LayoutView, "email.html"})
    |> subject("Proxy Password Reset")
    |> assign(:token, token)
    |> render("token_content.html")
  end
end
