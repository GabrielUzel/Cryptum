defmodule AuthService.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias AuthService.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import AuthService.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthService.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AuthService.Repo, {:shared, self()})
    end

    :ok
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
