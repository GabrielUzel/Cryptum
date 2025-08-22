defmodule Backend.GuardianAuth do
  use Guardian, otp_app: :backend
  alias Backend.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.email)}
  end

  def build_claims(claims, resource, _opts) do
    claims =
      claims
      |> Map.put("name", resource.name)
      |> Map.put("id", resource.id)
    {:ok, claims}
  end

  def resource_from_claims(%{"sub" => email}) do
    user = Accounts.get_user(email)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
