defmodule AuthService.AccountsFixtures do
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        password: "some password"
      })
      |> AuthService.Accounts.create_user()

    user
  end
end
