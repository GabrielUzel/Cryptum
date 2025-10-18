defmodule BackendWeb.UserSocket do
  use Phoenix.Socket
  channel "document:*", BackendWeb.DocumentChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, assign(socket, :current_user, %{id: :guest, role: "guest"})}
  end

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"

  defp authorized?(%{role: role}) when role in ["admin", "member"], do: true
  defp authorized?(_user), do: false
end
