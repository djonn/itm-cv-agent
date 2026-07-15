defmodule ItMinds.CvAgent.AgentInstance do
  # restart transient means it will only be restarted if it stopped unexpectedly
  use GenServer, restart: :transient

  alias Phoenix.PubSub

  alias ItMinds.CvAgent.LLM
  alias ItMinds.CvAgent.ProjectExperience
  alias ItMinds.CvAgent.AgentSupervisor

  defstruct [:instance_id, :phase, :context, :project_experience]

  @type t :: %__MODULE__{
          instance_id: {module(), String.t()},
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
    AgentSupervisor.via_syn(name, __MODULE__)
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

  def handle_cast({:prompt, message}, _from, state) do
    context = state.context |> ReqLLM.Context.append(ReqLLM.Context.user(message))
    {:ok, response} = ReqLLM.generate_text(ItMinds.CvAgent.LLM.model(), context)

    new_state =
      state
      |> Map.put(:context, response.context)

    broadcast_async_response(state.instance_id, new_state)

    {:no_reply, new_state}
  end

  def subscribe_async_response(name, agent_module) do
    :ok =
      PubSub.subscribe(
        ItMinds.CvAgent.PubSub,
        AgentSupervisor.via_syn(name, agent_module) |> inspect()
      )
  end

  def broadcast_async_response({name, agent_module}, message) do
    PubSub.broadcast(
      ItMinds.CvAgent.PubSub,
      AgentSupervisor.via_syn(name, agent_module) |> inspect(),
      {:async_response, message}
    )
  end
end
