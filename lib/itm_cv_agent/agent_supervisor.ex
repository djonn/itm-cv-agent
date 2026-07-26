defmodule ItMinds.CvAgent.AgentSupervisor do
  use DynamicSupervisor

  alias ItMinds.CvAgent.AgentInstance

  @supervisor_name :agents

  @type instance_id :: {agent_module :: module(), name :: String.t()}

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    :syn.add_node_to_scopes([@supervisor_name])
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def ensure_started(name, agent_module) do
    instance_id = instance_id(name, agent_module)
    ensure_started(instance_id)
  end

  def ensure_started(instance_id) do
    case start_server(instance_id) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      other -> other
    end
  end

  def start_server(name, agent_module) do
    instance_id = instance_id(name, agent_module)
    start_server(instance_id)
  end

  @spec start_server(instance_id()) :: DynamicSupervisor.on_start_child()
  def start_server(instance_id) do
    via_name = via_syn(instance_id)

    child_spec = %{
      id: AgentInstance,
      start: {AgentInstance, :start_link, [instance_id, [name: via_name]]}
    }

    DynamicSupervisor.start_child(
      __MODULE__,
      child_spec
    )
  end

  def find_server(name, agent_module) do
    instance_id = instance_id(name, agent_module)
    find_server(instance_id)
  end

  def find_server(instance_id) do
    {pid, _metadata} =
      :syn.lookup(
        @supervisor_name,
        instance_id
      )

    pid
  end

  def stop_server(name, agent_module) do
    instance_id = instance_id(name, agent_module)
    stop_server(instance_id)
  end

  def stop_server(instance_id) do
    via_syn(instance_id)
    |> GenServer.stop(:normal, 5000)
  end

  def instance_id(name, agent_module), do: {agent_module, name}

  def via_syn(instance_id),
    do: {:via, :syn, {@supervisor_name, instance_id}}
end
