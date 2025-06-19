defmodule ProjectManagerWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: ProjectManagerWeb

      import Plug.Conn
      import ProjectManagerWeb.Gettext
      alias ProjectManagerWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/project_manager_web/templates",
        namespace: ProjectManagerWeb

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
      import ProjectManagerWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      import Phoenix.View

      import ProjectManagerWeb.ErrorHelpers
      import ProjectManagerWeb.Gettext
      alias ProjectManagerWeb.Router.Helpers, as: Routes
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
