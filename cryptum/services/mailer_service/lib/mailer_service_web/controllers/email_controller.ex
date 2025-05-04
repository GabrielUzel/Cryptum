defmodule MailerServiceWeb.EmailController do
  use MailerServiceWeb, :controller

  def confirm_register(conn, %{"user" => user_email}) do
    conn
    |> json("ok")
  end
end
