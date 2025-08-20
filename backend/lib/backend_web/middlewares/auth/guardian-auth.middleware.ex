defmodule Backend.GuardianAuth do
  use Guardian, otp_app: :auth_service
  alias Backend.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.email)}
  end

  def resource_from_claims(%{"sub" => email}) do
    user = Accounts.get_user(email)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
