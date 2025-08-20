defmodule BackendWeb.UserSocket do
  use Phoenix.Socket
  channel "document:*", BackendWeb.DocumentChannel
  alias Backend.GuardianAuth

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case GuardianAuth.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, assign(socket, :current_user, user)}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
end
