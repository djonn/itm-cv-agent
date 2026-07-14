defmodule ItMinds.CvAgent.AgentSupervisor do
  use DynamicSupervisor

  alias ItMinds.CvAgent.AgentRegistry

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # def ensure_started(name, agent_module) do
  #   case via_registry(name, agent_module)
  #   |> GenServer.whereis() do
  #     nil -> start_server(name, agent_module)
  #   end
  # end

  @spec start_server(String.t(), module()) :: DynamicSupervisor.on_start_child()
  def start_server(name, agent_module),
    do:
      DynamicSupervisor.start_child(
        __MODULE__,
        {agent_module, name: via_registry(name, agent_module)}
      )

  def stop_server(name, agent_module) do
    via_registry(name, agent_module)
    |> GenServer.stop(:normal, 5000)
  end

  def via_registry(name, agent_module), do: {:via, Registry, {AgentRegistry, agent_module, name}}
end
