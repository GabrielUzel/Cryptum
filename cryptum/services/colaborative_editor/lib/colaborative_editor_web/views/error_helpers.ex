defmodule ColaborativeEditorWeb.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(ColaborativeEditorWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ColaborativeEditorWeb.Gettext, "errors", msg, opts)
    end
  end
end
