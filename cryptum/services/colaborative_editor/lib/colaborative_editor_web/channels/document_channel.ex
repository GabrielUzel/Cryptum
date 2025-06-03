defmodule ColaborativeEditorWeb.DocumentChannel do
  use Phoenix.Channel
  alias ColaborativeEditor.Document

  @impl true
  def join("doc", %{"filename" => filename}, socket) do
    {:ok, _pid} = Document.open(filename)
    socket = assign(socket, :filename, filename)
    send(self(), :after_join)

    {:ok, socket}
  end

  def join("doc", _payload, _socket) do
    {:error, %{reason: "filename required"}}
  end

  @impl true
  def handle_info(:after_join, socket) do
    response = Document.get_contents(socket.assigns.filename)
    push(socket, "open", response)

    {:noreply, socket}
  end

  @impl true
  def handle_in("update", %{"change" => change, "version" => version}, socket) do
    case Document.update(socket.assigns.filename, change, version) do
      {:ok, response} ->
        broadcast_from!(socket, "update", response)
        {:reply, {:ok, %{version: response.version}}, socket}

      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end
end
