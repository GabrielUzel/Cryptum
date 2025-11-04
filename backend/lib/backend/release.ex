defmodule Backend.Release do
  @app :backend

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def create_database do
    load_app()

    for repo <- repos() do
      case repo.__adapter__.storage_up(repo.config) do
        :ok -> :ok
        {:error, :already_up} -> :ok
        {:error, term} -> {:error, term}
      end
    end
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
