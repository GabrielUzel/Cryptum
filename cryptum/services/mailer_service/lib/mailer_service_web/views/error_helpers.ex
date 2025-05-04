defmodule MailerServiceWeb.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(MailerServiceWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MailerServiceWeb.Gettext, "errors", msg, opts)
    end
  end
end
