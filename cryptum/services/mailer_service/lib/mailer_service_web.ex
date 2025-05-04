defmodule MailerServiceWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: MailerServiceWeb

      import Plug.Conn
      import MailerServiceWeb.Gettext
      alias MailerServiceWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/mailer_service_web/templates",
        namespace: MailerServiceWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MailerServiceWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      import Phoenix.View

      import MailerServiceWeb.ErrorHelpers
      import MailerServiceWeb.Gettext
      alias MailerServiceWeb.Router.Helpers, as: Routes
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
