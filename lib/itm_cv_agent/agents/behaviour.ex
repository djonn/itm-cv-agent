defmodule ItMinds.CvAgent.Agents.Behaviour do
  @type tool_response ::
          {:ok, response :: String.t()}
          | {:ok, {:set_state, response :: String.t(), state_updator :: fun()}}

  @callback model() :: LLMDB.Model.t()
  @callback new_context() :: ReqLLM.Context.t()
  @callback new_state() :: term()
  @callback setup_tools(agent_state :: term()) :: list(ReqLLM.Tool.t())
end
