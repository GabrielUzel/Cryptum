defmodule Backend.Document do
  use GenServer
  alias Backend.Document.Supervisor
  alias TextDelta
  alias Backend.DeltaConverter

  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename, name: name(filename))
  end

  def get_contents(filename) do
    GenServer.call(name(filename), :get_contents)
  end

  def update(filename, change, version) do
    GenServer.call(name(filename), {:update, change, version})
  end

  def open(filename) do
    case GenServer.whereis(name(filename)) do
      nil ->
        DynamicSupervisor.start_child(Supervisor, {__MODULE__, filename})

      pid ->
        {:ok, pid}
    end
  end

  @impl true
  def init(filename) do
    path = Path.expand("temp/latex/#{filename}")

    content =
      case File.read(path) do
        {:ok, data} -> data
        {:error, _} -> ""
      end

    quill_delta = %{
      "ops" => [%{"insert" => content}]
    }

    text_delta = DeltaConverter.quill_to_text_delta(quill_delta)

    {:ok, %{filename: filename, content: text_delta, version: 0, changes: []}}
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
    client_change_converted = DeltaConverter.quill_to_text_delta(client_change)

    transformed_change =
      state.changes
      |> Enum.take(edits_since)
      |> Enum.reverse()
      |> Enum.reduce(client_change_converted, &TextDelta.transform(&1, &2, true))

    new_content = TextDelta.compose(state.content, transformed_change)

    new_state = %{
      state
      | version: state.version + 1,
        changes: [transformed_change | state.changes],
        content: new_content
    }

    path = Path.expand("temp/latex/#{new_state.filename}")
    File.write!(path, extract_text(new_content.ops))

    response = %{version: new_state.version, change: DeltaConverter.text_delta_to_quill(transformed_change)}
    {:reply, {:ok, response}, new_state}
  end

  defp name(filename), do: {:via, Registry, {Backend.Registry, filename}}

  defp extract_text(ops) when is_list(ops) do
    ops
    |> Enum.map(fn
      %{insert: text} when is_binary(text) -> text
      %{"insert" => text} when is_binary(text) -> text
      _ -> ""
    end)
    |> Enum.join()
  end
end
