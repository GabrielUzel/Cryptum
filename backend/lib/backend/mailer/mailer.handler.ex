defmodule BackendWeb.MailerHandler do
  alias Backend.Mailer
  import Swoosh.Email

  def confirm_register(user_email, confirmation_link) do
    email_body = """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Confirmação de Cadastro</title>
    </head>
    <body style="margin:0; padding:0; background:#ffffff;">
        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width: 600px; margin: 0 auto;">
            <tr>
                <td style="padding: 30px 20px; background: #ffffff;">
                    <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="text-align: center; padding-bottom: 20px;">
                                <h1 style="color: #333333; margin:0; font-size: 24px; font-family: Arial, sans-serif;">
                                    Confirmação de Cadastro
                                </h1>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align: center; padding-bottom: 25px; font-family: Arial, sans-serif; color: #666666; font-size: 16px; line-height: 1.5;">
                                Olá, clique no botão abaixo para confirmar a criação da sua conta
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align: center; padding-bottom: 30px;">
                                <table role="presentation" border="0" cellspacing="0" cellpadding="0" style="margin: 0 auto;">
                                    <tr>
                                        <td style="background: #007EA7; border-radius: 10px; padding: 12px 25px;">
                                            <a href="#{confirmation_link}" style="color: #ffffff; text-decoration: none; font-family: Arial, sans-serif; font-size: 16px; display: block;">
                                                Confirmar e-mail
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="border-top: 1px solid #e0e0e0; padding: 20px 0 5px 0;"></td>
                        </tr>
                    </table>
                    <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="text-align: center; padding-top: 15px; font-family: Arial, sans-serif; color: #999999; font-size: 12px;">
                                Esta é uma mensagem automática. Por favor, não responda a este e-mail.
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
    </html>
    """

    email =
      new()
      |> to({nil, user_email})
      |> from({"Cryptum", "gabrieluzelwork@gmail.com"})
      |> subject("Confirmação de Cadastro")
      |> html_body(email_body)

    Mailer.deliver(email)
  end

  def reset_password(user_email) do
    # TODO: Implementar corpo do email
    email_body = """

    """

    email =
      new()
      |> to({nil, user_email})
      |> from({"Cryptum", "gabrieluzelwork@gmail.com"})
      |> subject("Redefinição de Senha")
      |> html_body(email_body)

    Mailer.deliver(email)
  end
end
