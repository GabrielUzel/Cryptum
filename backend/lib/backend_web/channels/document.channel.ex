defmodule BackendWeb.DocumentChannel do
  use Phoenix.Channel
  alias Backend.Document
  alias Backend.Files.FilesService
  alias Backend.Projects.ProjectsService

  @impl true
  def join("document:" <> file_id, _payload, socket) do
    user_id = socket.assigns.current_user.id

    case FilesService.get_file_project_id(file_id) do
      nil ->
        {:error, %{reason: "file_not_found"}}

      project_id ->
        case ProjectsService.is_at_least_guest?(user_id, project_id) do
          true ->
            role = ProjectsService.get_user_role(user_id, project_id)

            {:ok, _pid} = Document.open(file_id)
            Document.channel_joined(file_id)

            socket =
              socket
              |> assign(:file_id, file_id)
              |> assign(:project_id, project_id)
              |> assign(:user_role, role)

            send(self(), :after_join)
            {:ok, socket}

          false ->
            {:error, %{reason: "unauthorized"}}
        end
    end
  end

  def join("doc", _payload, _socket) do
    {:error, %{reason: "filename required"}}
  end

  @impl true
  def terminate(_reason, socket) do
    if file_id = socket.assigns[:file_id] do
      Document.channel_left(file_id)
    end

    :ok
  end

  @impl true
  def handle_info(:after_join, socket) do
    response = Document.get_contents(socket.assigns.file_id)
    enhanced_response = Map.put(response, :user_role, socket.assigns.user_role)
    push(socket, "open", enhanced_response)

    {:noreply, socket}
  end

  @impl true
  def handle_in("update", %{"change" => change, "version" => version}, socket) do
    if can_edit?(socket.assigns.user_role) do
      case Document.update(socket.assigns.file_id, change, version) do
        {:ok, response} ->
          broadcast_from!(socket, "update", response)
          {:reply, {:ok, %{version: response.version}}, socket}

        {:error, reason} ->
          {:reply, {:error, reason}, socket}
      end
    else
      {:reply, {:error, %{reason: "unauthorized"}}, socket}
    end
  end

  defp can_edit?("guest"), do: false
  defp can_edit?(_role), do: true
end
