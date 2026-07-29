defmodule ItMinds.CvAgent.Agents.Interviewer do
  alias ReqLLM.{Context, Tool}
  alias ItMinds.CvAgent.{AgentInstance, AgentSupervisor, ProjectExperience}

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
      Context.system(interviewer_system_prompt())
    ])
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def new_state() do
    %ProjectExperience{}
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def setup_tools(_state) do
    [
      write_project_experience_tool(),
      subagent_tool()
    ]
  end

  @interviewer_system_prompt File.read!("lib/itm_cv_agent/llm/interviewer-agent.md")

  defp interviewer_system_prompt() do
    [
      @interviewer_system_prompt,
      env_prompt()
    ]
    |> Enum.map(&String.trim(&1))
    |> Enum.join("\n\n---\n\n")
  end

  defp env_prompt(),
    do: """
    <env>
      Today's date: #{Date.utc_today() |> DateExtension.to_string()}
    </env>
    """

  @spec write_project_experience_tool() :: ReqLLM.Tool.t()
  defp write_project_experience_tool() do
    Tool.new!(
      name: "write_project_experience",
      description: "Write a segment of the project experience",
      parameter_schema: [
        section: [
          type:
            {:in,
             [
               "customer_name",
               "project_name",
               "project_description",
               "employee_role_name",
               "employee_role_description",
               "competencies",
               "start_date",
               "end_date",
               "employee_name"
             ]},
          required: true,
          doc: "What section to write to"
        ],
        language: [
          type: {:in, ["da", "en"]},
          required: false,
          default: "da",
          doc: "Write default danish file or english translation"
        ],
        value: [
          type: :string,
          required: true,
          doc: "The new content of the section, everything in the section will be overridden"
        ]
      ],
      # callback is not actually used as it is specially handled in agent_instance
      callback: fn %{section: section, value: value} ->
        state_updator = &Map.put(&1, section, value)
        {:set_state, "Succesfully updated project experience", state_updator}
      end
    )
  end

  defp subagent_tool() do
    Tool.new!(
      name: "Task",
      description: "Interact with a subagent",
      parameter_schema: [
        agent: [
          type: {:in, ["translator"]},
          required: true,
          doc: "The subagent to call upon"
        ],
        message: [
          type: :string,
          required: true,
          doc:
            "The message to call the subagent with. Any previous calls to the same subagent with remain in their context."
        ]
      ],
      callback: fn %{message: message} ->
        AgentSupervisor.ensure_started("1", ItMinds.CvAgent.Agents.Translator)
        response = AgentInstance.send_prompt_sync("1", ItMinds.CvAgent.Agents.Translator, message)
        {:ok, response}
      end
    )
  end
end
