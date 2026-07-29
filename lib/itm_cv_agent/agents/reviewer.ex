defmodule ItMinds.CvAgent.Agents.Reviewer do
  alias ReqLLM.Context

  @behaviour ItMinds.CvAgent.Agents.Behaviour

  @impl ItMinds.CvAgent.Agents.Behaviour
  def model() do
    ReqLLM.model!(%{
      provider: :openai,
      id: "qwen/qwen3.6-35b-a3b:bf16",
      base_url: "https://api.scaleway.ai/05232108-8415-474e-b3f6-fe485984e92d/v1"
    })
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def new_context() do
    Context.new([
      Context.system(reviewer_system_prompt())
    ])
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def new_state() do
    nil
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def setup_tools(_state) do
    []
  end

  @reviewer_system_prompt File.read!("lib/itm_cv_agent/llm/review-agent.md")

  defp reviewer_system_prompt(), do: @reviewer_system_prompt
end
