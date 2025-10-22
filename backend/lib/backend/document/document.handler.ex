defmodule Backend.Document do
  use GenServer
  require Logger

  alias Backend.Document.Supervisor
  alias TextDelta
  alias Backend.DeltaConverter
  alias Backend.Files.FilesService

  @save_interval 5_000

  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename, name: name(filename))
  end

  def open(filename) do
    case GenServer.whereis(name(filename)) do
      nil ->
        Logger.info("Starting new Document process for: #{filename}")
        DynamicSupervisor.start_child(Supervisor, {__MODULE__, filename})

      pid ->
        {:ok, pid}
    end
  end

  def channel_joined(filename), do: GenServer.cast(name(filename), :channel_joined)
  def channel_left(filename), do: GenServer.cast(name(filename), :channel_left)
  def get_contents(filename), do: GenServer.call(name(filename), :get_contents)

  def update(filename, change, version),
    do: GenServer.call(name(filename), {:update, change, version})

  @impl true
  def init(filename) do
    dir_path = Path.expand("temp/latex")
    File.mkdir_p!(dir_path)
    local_path = Path.join(dir_path, filename)

    content = load_content_from_azure(filename)
    quill_delta = %{"ops" => [%{"insert" => content || ""}]}
    text_delta = DeltaConverter.quill_to_text_delta(quill_delta)

    state = %{
      filename: filename,
      content: text_delta,
      version: 0,
      changes: [],
      dirty: false,
      channel_count: 0,
      local_path: local_path,
      autosave_timer: nil,
      file_created: false
    }

    {:ok, state}
  end

  defp load_content_from_azure(filename) do
    case FilesService.get_document_content(filename) do
      {:ok, blob} when is_binary(blob) and blob != "" ->
        blob

      {:ok, _blob} ->
        ""

      {:error, :not_found} ->
        ""

      {:error, reason} ->
        Logger.error("Error loading from Azure for #{filename}: #{inspect(reason)}")
        ""

      _ ->
        ""
    end
  end

  @impl true
  def handle_cast(:channel_joined, state) do
    new_state =
      if state.channel_count == 0 do
        content_to_write = extract_text_with_newlines(state.content.ops)

        case File.write(state.local_path, content_to_write) do
          :ok ->
            timer = Process.send_after(self(), :autosave, @save_interval)
            %{state | autosave_timer: timer, file_created: true}

          {:error, reason} ->
            Logger.error("Failed to create temp file for #{state.filename}: #{inspect(reason)}")
            state
        end
      else
        state
      end

    {:noreply, %{new_state | channel_count: state.channel_count + 1}}
  end

  @impl true
  def handle_cast(:channel_left, state) do
    new_count = max(0, state.channel_count - 1)

    if new_count == 0 do
      cleanup_resources(state)
      {:stop, :normal, %{state | channel_count: 0}}
    else
      {:noreply, %{state | channel_count: new_count}}
    end
  end

  defp cleanup_resources(state) do
    if state.autosave_timer do
      Process.cancel_timer(state.autosave_timer)
    end

    if state.dirty do
      content_to_save = extract_text_with_newlines(state.content.ops)

      case FilesService.update_file(state.filename, content_to_save) do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          Logger.error("Failed to save #{state.filename} to Azure: #{inspect(reason)}")
      end
    end

    # Remove temp file
    if state.file_created do
      case File.rm(state.local_path) do
        :ok ->
          :ok

        {:error, :enoent} ->
          :ok

        {:error, reason} ->
          Logger.error("Failed to remove temp file #{state.local_path}: #{inspect(reason)}")
      end
    end
  end

  @impl true
  def handle_call(:get_contents, _from, state) do
    response = %{
      version: state.version,
      content: DeltaConverter.text_delta_to_quill(state.content)
    }

    {:reply, response, state}
  end

  @impl true
  def handle_call({:update, client_change, client_version}, _from, state) do
    edits_since = state.version - client_version

    case edits_since do
      x when x < 0 ->
        {:reply, {:error, :version_too_high}, state}

      x when x > 100 ->
        {:reply, {:error, :version_too_old}, state}

      _ ->
        client_change_converted = DeltaConverter.quill_to_text_delta(client_change)

        new_content = TextDelta.compose(state.content, client_change_converted)

        new_state = %{
          state
          | version: state.version + 1,
            changes: [client_change_converted | state.changes],
            content: new_content,
            dirty: true
        }

        response = %{
          version: new_state.version,
          change: DeltaConverter.text_delta_to_quill(client_change_converted)
        }

        {:reply, {:ok, response}, new_state}
    end
  end

  @impl true
  def handle_info(:autosave, state) do
    new_state =
      if state.dirty do
        content_to_save = extract_text_with_newlines(state.content.ops)

        if state.file_created do
          case File.write(state.local_path, content_to_save) do
            :ok ->
              :ok

            {:error, reason} ->
              Logger.error("Failed to update temp file #{state.local_path}: #{inspect(reason)}")
          end
        end

        case FilesService.update_file(state.filename, content_to_save) do
          {:ok, _} ->
            :ok

          {:error, reason} ->
            Logger.error("Autosave failed for #{state.filename}: #{inspect(reason)}")
        end

        %{state | dirty: false}
      else
        state
      end

    if state.channel_count > 0 do
      timer = Process.send_after(self(), :autosave, @save_interval)
      {:noreply, %{new_state | autosave_timer: timer}}
    else
      {:noreply, %{new_state | autosave_timer: nil}}
    end
  end

  @impl true
  def terminate(_reason, state) do
    cleanup_resources(state)
    :ok
  end

  defp name(filename), do: {:via, Registry, {Backend.Registry, filename}}

  defp extract_text_with_newlines(ops) when is_list(ops) do
    ops
    |> Enum.map(fn
      %{insert: content} when is_binary(content) -> content
      %{insert: "\n"} -> "\n"
      _ -> ""
    end)
    |> Enum.join()
  end
end
