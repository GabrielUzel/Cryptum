defmodule LatexCompilerWeb.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(LatexCompilerWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LatexCompilerWeb.Gettext, "errors", msg, opts)
    end
  end
end
