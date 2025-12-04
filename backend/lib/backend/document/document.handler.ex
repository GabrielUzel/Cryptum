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
    {:noreply, %{state | channel_count: state.channel_count + 1}}
  end

  @impl true
  def handle_cast(:channel_left, state) do
    new_count = max(0, state.channel_count - 1)
    {:noreply, %{state | channel_count: new_count}}
  end

  defp load_content_from_azure(filename) do
    case FilesService.get_document_content(filename) do
      {:ok, blob} when is_binary(blob) -> blob
      _ -> ""
    end
  end

  defp transform(opA, opB) do
    case TextDelta.transform(opA, opB) do
      {:ok, transformed} ->
        transformed

      :error ->
        opA
    end
  end
end
