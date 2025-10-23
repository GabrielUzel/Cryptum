defmodule BackendWeb.UserSocket do
  use Phoenix.Socket
  channel "document:*", BackendWeb.DocumentChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Backend.GuardianAuth.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, assign(socket, :current_user, %{id: user.id})}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
end
