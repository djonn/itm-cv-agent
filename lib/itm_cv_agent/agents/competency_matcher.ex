defmodule ItMinds.CvAgent.Agents.CompetencyMatcher do
  alias ReqLLM.{Context, Tool}

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
      Context.system(competency_matcher_system_prompt())
    ])
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def new_state() do
    []
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def setup_tools(_state) do
    [write_competencies_tool()]
  end

  defp write_competencies_tool() do
    Tool.new!(
      name: "write_competencies",
      description: "Write a list of competencies for the project experience",
      parameter_schema: [
        competencies: [
          type: {:list, :string},
          required: true,
          doc: "The new content of the section, everything in the section will be overridden"
        ]
      ],
      callback: fn %{competencies: competencies} ->
        state_updator = fn _ -> competencies end
        {:set_state, "Competencies updated", state_updator}
      end
    )
  end

  @competency_matcher_system_prompt File.read!("lib/itm_cv_agent/llm/competency-agent.md")

  defp competency_matcher_system_prompt(), do: @competency_matcher_system_prompt
end
