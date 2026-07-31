defmodule ItMinds.CvAgent.AgentInstance do
  # restart transient means it will only be restarted if it stopped unexpectedly
  use GenServer, restart: :transient

  alias Phoenix.PubSub

  alias ItMinds.CvAgent.AgentSupervisor
  alias ReqLLM.Tool

  defstruct [:instance_id, :context, :agent_module, :agent_state]

  @type instance_id_t :: {module(), String.t()}

  @type t :: %__MODULE__{
          instance_id: instance_id_t(),
          context: ReqLLM.Context.t(),
          agent_module: module(),
          agent_state: term()
        }

  # Public
  def start_link(instance_id, opts) do
    GenServer.start_link(__MODULE__, instance_id, opts)
  end

  def send_prompt(name, agent_module, message) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.cast({:prompt, message})
  end

  def send_prompt_sync(name, agent_module, message) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.call({:prompt, message})
  end

  def get_state(name, agent_module) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.call(:get_state)
  end

  def set_state(name, agent_module, new_state) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.call({:set_state, new_state})
  end

  def get_agent_state(name, agent_module) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.call(:get_agent_state)
  end

  def set_agent_state(name, agent_module, new_agent_state) do
    AgentSupervisor.find_server(name, agent_module)
    |> GenServer.call({:set_agent_state, new_agent_state})
  end

  # Private
  def init({agent_module, _name} = instance_id) do
    {:ok,
     %__MODULE__{
       instance_id: instance_id,
       context: agent_module.new_context(),
       agent_module: agent_module,
       agent_state: agent_module.new_state()
     }}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:set_state, new_state}, _from, _old_state) do
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(:get_agent_state, _from, state) do
    {:reply, {:ok, state |> Map.get(:agent_state)}, state}
  end

  def handle_call({:set_agent_state, new_agent_state}, _from, old_state) do
    new_state = old_state |> Map.put(:agent_state, new_agent_state)
    {:reply, {:ok, new_agent_state}, new_state}
  end

  def handle_call({:prompt, message}, _from, state) do
    context = state.context |> ReqLLM.Context.append(ReqLLM.Context.user(message))
    state = state |> Map.put(:context, context)
    new_state = handle_llm(state)

    response =
      new_state.context.messages
      |> List.last()
      |> then(& &1.content)
      |> Enum.find(fn part -> part.type == :text end)
      |> then(& &1.text)

    {:reply, response, new_state}
  end

  # Cast means it is not awaited, while Call is syncronous
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
        tool_call_executions =
          last_message
          |> Map.get(:tool_calls, [])
          |> Enum.map(fn %{id: id, function: function} ->
            tool =
              Enum.find(state.agent_module.setup_tools(state.agent_state), fn t ->
                t.name == function.name
              end)

            tool_with_state = add_state_to_tool_parameters(tool)

            result =
              ReqLLM.Tool.execute(
                tool_with_state,
                Jason.decode!(function.arguments, keys: :atoms)
                |> Map.put(:state, state.agent_state)
              )

            {id, result}
          end)

        tool_call_results =
          tool_call_executions
          |> Enum.map(fn {id, result} ->
            response =
              case result do
                {:ok, response} when is_binary(response) ->
                  response

                {:ok, nil} ->
                  "<empty-response/>"

                {:set_state, response, _} ->
                  response

                {:error, %ReqLLM.Error.Validation.Error{reason: reason}} ->
                  # In case of callback validation error, just tell the agent what the error was
                  reason

                {:error, error} ->
                  raise error
              end

            ReqLLM.Context.tool_result(id, response)
          end)

        context = ReqLLM.Context.append(state.context, tool_call_results)

        new_agent_state =
          tool_call_executions
          |> Enum.filter(&is_set_state_result?(&1))
          |> Enum.reduce(
            state.agent_state,
            fn {_tool_call_id, {:set_state, _response, state_updator}}, acc ->
              state_updator.(acc)
            end
          )

        response = call_llm(state |> Map.put(:context, context))

        handle_llm(
          state
          |> Map.put(:context, response.context)
          |> Map.put(:agent_state, new_agent_state)
        )

      true ->
        state
    end
  end

  defp call_llm(state) do
    {:ok, stream_response} =
      ReqLLM.stream_text(
        state.agent_module.model(),
        state.context,
        tools: state.agent_module.setup_tools(state.agent_state)
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

  @spec is_set_state_result?(ItMinds.CvAgent.Agents.Behaviour.tool_response()) :: boolean()
  defp is_set_state_result?({_tool_call_id, {:set_state, _response, _state_updator}}), do: true
  defp is_set_state_result?(_tool_call_execution), do: false

  defp add_state_to_tool_parameters(%Tool{} = tool) do
    parameter_schema = Map.get(tool, :parameter_schema, []) ++ [state: [type: :any]]

    Tool.new!(
      name: tool.name,
      description: tool.description,
      parameter_schema: parameter_schema,
      callback: tool.callback,
      strict: Map.get(tool, :strict, false),
      provider_options: Map.get(tool, :provider_options, %{})
    )
  end

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
