defmodule Backend.Document do
  use GenServer
  require Logger

  alias Backend.Document.Supervisor
  alias TextDelta
  alias Backend.DeltaConverter
  alias Backend.Files.FilesService

  @save_interval 5_000

  defp name(filename) do
    {:via, Registry, {Backend.Registry, filename}}
  end

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

  def update(filename, op, base_version) do
    GenServer.call(name(filename), {:client_update, op, base_version})
  end

  @impl true
  def init(filename) do
    content = load_content_from_azure(filename)
    quill_delta = %{"ops" => [%{"insert" => content}]}
    text_delta = DeltaConverter.quill_to_text_delta(quill_delta)

    state = %{
      filename: filename,
      content: text_delta,
      version: 0,
      ops: [],
      channel_count: 0,
      local_path: "temp/latex/#{filename}",
      dirty: false,
      autosave_timer: nil
    }

    {:ok, state}
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
  def handle_call({:client_update, client_quill_op, base_version}, _from, state) do
    client_op = DeltaConverter.quill_to_text_delta(client_quill_op)

    if base_version > state.version do
      {:reply, {:error, :invalid_version}, state}
    else
      ops_since = Enum.drop(state.ops, base_version)

      transformed_op =
        Enum.reduce(ops_since, client_op, fn server_op, acc ->
          transform(acc, server_op)
        end)

      new_content = TextDelta.compose(state.content, transformed_op)

      new_state = %{
        state
        | content: new_content,
          ops: state.ops ++ [transformed_op],
          version: state.version + 1,
          dirty: true
      }

      response = %{
        version: new_state.version,
        op: DeltaConverter.text_delta_to_quill(transformed_op)
      }

      {:reply, {:ok, response}, new_state}
    end
  end

  @impl true
  def handle_cast(:channel_joined, state) do
    new_state =
      if state.channel_count == 0 do
        # inicia autosave quando o primeiro cliente entra
        timer = Process.send_after(self(), :autosave, @save_interval)
        %{state | autosave_timer: timer}
      else
        state
      end

    {:noreply, %{new_state | channel_count: state.channel_count + 1}}
  end

  @impl true
  def handle_cast(:channel_left, state) do
    new_count = max(0, state.channel_count - 1)

    if new_count == 0 do
      # último cliente saiu: faz um save final se estiver sujo e encerra
      cleanup_resources(state)
      {:stop, :normal, %{state | channel_count: 0}}
    else
      {:noreply, %{state | channel_count: new_count}}
    end
  end

  @impl true
  def handle_info(:autosave, state) do
    new_state =
      if state.dirty do
        content_to_save = extract_text_from_delta(state.content)

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

    if new_state.channel_count > 0 do
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

  # ---------- helpers ----------

  defp load_content_from_azure(filename) do
    case FilesService.get_document_content(filename) do
      {:ok, blob} when is_binary(blob) -> blob
      _ -> ""
    end
  end

  # converte text_delta -> string LaTeX
  defp extract_text_from_delta(text_delta) do
    quill = DeltaConverter.text_delta_to_quill(text_delta)

    quill["ops"]
    |> Enum.map(fn
      %{"insert" => content} -> content
      _ -> ""
    end)
    |> Enum.join()
  end

  defp cleanup_resources(state) do
    if state.autosave_timer do
      Process.cancel_timer(state.autosave_timer)
    end

    if state.dirty do
      content_to_save = extract_text_from_delta(state.content)

      case FilesService.update_file(state.filename, content_to_save) do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          Logger.error("Failed to save #{state.filename} to Azure on cleanup: #{inspect(reason)}")
      end
    end
  end

  defp transform(client_op, server_op) do
    TextDelta.transform(server_op, client_op, :left)
  end
end
