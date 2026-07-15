defmodule ItMinds.CvAgent.AgentInstance do
  # restart transient means it will only be restarted if it stopped unexpectedly
  use GenServer, restart: :transient

  alias Phoenix.PubSub

  alias ItMinds.CvAgent.LLM
  alias ItMinds.CvAgent.ProjectExperience
  alias ItMinds.CvAgent.AgentSupervisor

  defstruct [:instance_id, :phase, :context, :project_experience]

  @type instance_id_t :: {module(), String.t()}

  @type t :: %__MODULE__{
          instance_id: instance_id_t(),
          phase:
            :setup
            | :customer_interview
            | :developer_role_interview
            | :review
            | :competency_matching
            | :translation,
          context: ReqLLM.Context.t(),
          project_experience: ProjectExperience.t()
        }

  # Public
  def start_link(instance_id, opts) do
    GenServer.start_link(__MODULE__, instance_id, opts)
  end

  def send_prompt(name, message) do
    AgentSupervisor.find_server(name, __MODULE__)
    |> GenServer.cast({:prompt, message})
  end

  # Private
  def init(instance_id) do
    {:ok,
     %__MODULE__{
       instance_id: instance_id,
       phase: :setup,
       context: LLM.new_context(),
       project_experience: %ProjectExperience{}
     }}
  end

  def handle_cast({:prompt, message}, state) do
    context = state.context |> ReqLLM.Context.append(ReqLLM.Context.user(message))

    {:ok, response} = ReqLLM.generate_text(ItMinds.CvAgent.LLM.model(), context)


    new_state = Map.put(state, :context, response.context)

    broadcast_new_state(state.instance_id, new_state)

    {:noreply, new_state}
  end

  @spec broadcast_new_state(String.t(), module()) :: :ok
  def subscribe(name, agent_module) do
    :ok =
      PubSub.subscribe(
        ItMinds.CvAgent.PubSub,
        "#{agent_module}:#{name}"
      )
  end

  @spec broadcast_new_state(instance_id_t(), term()) :: :ok | {:error, term()}
  def broadcast_new_state({agent_module, name}, message) do
    PubSub.broadcast(
      ItMinds.CvAgent.PubSub,
      "#{agent_module}:#{name}",
      {:new_state, message}
    )
  end
end
