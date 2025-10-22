defmodule Backend.Document.Supervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  @spec init(:ok) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_children: 100,
      restart: :temporary
    )
  end
end
