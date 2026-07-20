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

  def get_state(name) do
    AgentSupervisor.find_server(name, __MODULE__)
    |> GenServer.call(:get_state)
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

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:prompt, message}, state) do
    context = state.context |> ReqLLM.Context.append(ReqLLM.Context.user(message))
    state = state |> Map.put(:context, context)
    new_state = handle_llm(state)

    broadcast(state.instance_id, {:new_state, new_state})

    {:noreply, new_state}
  end

  defp handle_llm(state) do
    last_message = state.context.messages |> List.last()

    cond do
      is_user_prompt?(last_message) ->
        response = call_llm(state)
        state = state |> Map.put(:context, response.context)
        handle_llm(state)

      has_tool_call?(last_message) ->
        tool_results =
          last_message.tool_calls
          |> Enum.map(fn %{id: id, function: function} ->
            tool = Enum.find(LLM.setup_tools(), fn t -> t.name == function.name end)
            {:ok, result} = ReqLLM.Tool.execute(tool, Jason.decode!(function.arguments))
            ReqLLM.Context.tool_result(id, result)
          end)

        context =
          ReqLLM.Context.append(
            state.context,
            tool_results
          )

        response = call_llm(state |> Map.put(:context, context))
        handle_llm(state |> Map.put(:context, response.context))

      true ->
        state
    end
  end

  defp call_llm(state) do
    {:ok, stream_response} =
      ReqLLM.stream_text(
        LLM.model(),
        state.context,
        tools: LLM.setup_tools()
      )

    {:ok, response} =
      ReqLLM.StreamResponse.process_stream(stream_response,
        on_result: fn chunk ->
          broadcast(
            state.instance_id,
            {:update_stream, %{id: System.unique_integer(), message: chunk}}
          )
        end
      )

    response
  end

  defp is_user_prompt?(message) do
    message.role == :user
  end

  defp has_tool_call?(%{tool_calls: tool_calls}) when is_list(tool_calls) do
    tool_calls |> Enum.any?()
  end

  defp has_tool_call?(_message), do: false

  @spec subscribe(String.t(), module()) :: :ok
  def subscribe(name, agent_module) do
    :ok =
      PubSub.subscribe(
        ItMinds.CvAgent.PubSub,
        "#{agent_module}:#{name}"
      )
  end

  @spec broadcast(instance_id_t(), term()) :: :ok | {:error, term()}
  def broadcast({agent_module, name}, message) do
    PubSub.broadcast(
      ItMinds.CvAgent.PubSub,
      "#{agent_module}:#{name}",
      message
    )
  end
end
