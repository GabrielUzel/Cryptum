defmodule LatexCompilerWeb.Router do
  use LatexCompilerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LatexCompilerWeb do
    pipe_through :api

    post "/compile", CompilerController, :compile
  end
end
