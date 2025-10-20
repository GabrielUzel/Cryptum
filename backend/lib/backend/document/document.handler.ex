defmodule Backend.Document do
  use GenServer
  alias Backend.Document.Supervisor
  alias TextDelta
  alias Backend.DeltaConverter
  alias Backend.Files.FilesService

  @save_interval 5_000
  @cleanup_delay 5_000
  @latex_dir Path.expand("temp/latex")

  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename, name: name(filename))
  end

  def open(filename) do
    case GenServer.whereis(name(filename)) do
      nil ->
        DynamicSupervisor.start_child(Supervisor, {__MODULE__, filename})

      pid ->
        {:ok, pid}
    end
  end

  def channel_joined(filename) do
    GenServer.call(name(filename), :channel_joined)
  end

  def channel_left(filename) do
    GenServer.call(name(filename), :channel_left)
  end

  def get_contents(filename) do
    GenServer.call(name(filename), :get_contents)
  end

  def update(filename, change, version) do
    GenServer.call(name(filename), {:update, change, version})
  end

  @impl true
  def init(filename) do
    path = Path.join(@latex_dir, filename)

    content =
      case File.read(path) do
        {:ok, data} ->
          String.trim_trailing(data)

        {:error, :enoent} ->
          case FilesService.get_document_content(filename) do
            {:ok, blob_data} ->
              case File.write(path, blob_data, [:binary]) do
                :ok -> String.trim_trailing(blob_data)
                {:error, _} -> ""
              end

            {:error, _} ->
              ""
          end

        {:error, _} ->
          ""
      end

    quill_delta = %{"ops" => [%{"insert" => content}]}
    text_delta = DeltaConverter.quill_to_text_delta(quill_delta)

    state = %{
      filename: filename,
      content: text_delta,
      version: 0,
      changes: [],
      dirty: false,
      channel_count: 0,
      cleanup_timer: nil
    }

    Process.send_after(self(), :autosave, @save_interval)

    {:ok, state}
  end

  @impl true
  def handle_call(:channel_joined, _from, state) do
    if state.cleanup_timer do
      Process.cancel_timer(state.cleanup_timer)
    end

    new_state = %{
      state
      | channel_count: state.channel_count + 1,
        cleanup_timer: nil
    }

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:channel_left, _from, state) do
    new_count = max(0, state.channel_count - 1)

    new_state =
      if new_count == 0 do
        timer = Process.send_after(self(), :cleanup, @cleanup_delay)
        %{state | channel_count: new_count, cleanup_timer: timer}
      else
        %{state | channel_count: new_count}
      end

    {:reply, :ok, new_state}
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
      edits_since when edits_since < 0 ->
        {:reply, {:error, :version_too_high}, state}

      edits_since when edits_since > 100 ->
        {:reply, {:error, :version_too_old}, state}

      edits_since ->
        client_change_converted = DeltaConverter.quill_to_text_delta(client_change)

        transformed_change =
          state.changes
          |> Enum.take(edits_since)
          |> Enum.reverse()
          |> Enum.reduce(client_change_converted, &TextDelta.transform(&1, &2, :right))

        new_content = TextDelta.compose(state.content, transformed_change)

        new_state = %{
          state
          | version: state.version + 1,
            changes: [transformed_change | state.changes],
            content: new_content,
            dirty: true
        }

        response = %{
          version: new_state.version,
          change: DeltaConverter.text_delta_to_quill(transformed_change)
        }

        {:reply, {:ok, response}, new_state}
    end
  end

  @impl true
  def handle_info(:cleanup, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(:autosave, state) do
    new_state =
      if state.dirty do
        content_to_save = extract_text(state.content.ops)

        path = Path.join(@latex_dir, state.filename)

        File.write!(path, content_to_save)

        %{state | dirty: false}
      else
        state
      end

    Process.send_after(self(), :autosave, @save_interval)
    {:noreply, new_state}
  end

  @impl true
  def terminate(_reason, state) do
    path = Path.join(@latex_dir, state.filename)

    if state.dirty do
      content_to_save = extract_text(state.content.ops)
      File.write!(path, content_to_save, [:binary])
    end

    File.rm(path)

    :ok
  end

  defp name(filename), do: {:via, Registry, {Backend.Registry, filename}}

  defp extract_text(ops) when is_list(ops) do
    text =
      ops
      |> Enum.map(fn
        %{insert: content} when is_binary(content) -> content
        _ -> ""
      end)
      |> Enum.join()

    String.trim_trailing(text)
  end
end
