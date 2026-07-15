defmodule ItMinds.CvAgent.AgentSupervisor do
  use DynamicSupervisor

  @supervisor_name :agents

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    :syn.add_node_to_scopes([@supervisor_name])
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def ensure_started(name, agent_module) do
    case start_server(name, agent_module) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      other -> other
    end
  end

  @spec start_server(String.t(), module()) :: DynamicSupervisor.on_start_child()
  def start_server(name, agent_module) do
    instance_id = instance_id(name, agent_module)
    via_name = via_syn(name, agent_module)

    child_spec = %{
      id: agent_module,
      start: {agent_module, :start_link, [instance_id, [name: via_name]]}
    }

    DynamicSupervisor.start_child(
      __MODULE__,
      child_spec
    )
  end

  def find_server(name, agent_module) do
    {pid, _metadata} =
      :syn.lookup(
        @supervisor_name,
        instance_id(name, agent_module)
      )

    pid
  end

  def stop_server(name, agent_module) do
    via_syn(name, agent_module)
    |> GenServer.stop(:normal, 5000)
  end

  def instance_id(name, agent_module), do: {agent_module, name}

  def via_syn(name, agent_module),
    do: {:via, :syn, {@supervisor_name, instance_id(name, agent_module)}}
end
