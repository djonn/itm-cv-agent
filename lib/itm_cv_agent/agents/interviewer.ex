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
      reviewer_agent_tool(),
      translator_agent_tool(),
      competency_matcher_agent_tool()
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
               #  "competencies",
               "start_date",
               "end_date",
               "employee_name"
             ]},
          required: true,
          doc: "What section to write to"
        ],
        value: [
          type: :string,
          required: true,
          doc: "The new content of the section, everything in the section will be overridden"
        ]
      ],
      callback: fn %{section: section, value: value} ->
        state_updator = &Map.put(&1, section |> String.to_atom(), value)
        {:set_state, "Succesfully updated project experience", state_updator}
      end
    )
  end

  defp translator_agent_tool() do
    Tool.new!(
      name: "translate",
      description: "Translate the project experience from danish to english.",
      parameter_schema: [],
      callback: fn %{state: state} ->
        AgentSupervisor.ensure_started("1", ItMinds.CvAgent.Agents.Translator)

        initial_translator_state =
          AgentInstance.get_agent_state("1", ItMinds.CvAgent.Agents.Translator)
          |> elem(1)
          |> Map.put("da", state)

        {:ok, _} =
          AgentInstance.set_agent_state(
            "1",
            ItMinds.CvAgent.Agents.Translator,
            initial_translator_state
          )

        response =
          AgentInstance.send_prompt_sync(
            "1",
            ItMinds.CvAgent.Agents.Translator,
            "Go ahead and translate"
          )

        # TODO: persist this somehow
        _translated =
          AgentInstance.get_agent_state("1", ItMinds.CvAgent.Agents.Translator)
          |> elem(1)
          |> Map.get("en")

        {:ok, response}
      end
    )
  end

  defp reviewer_agent_tool() do
    Tool.new!(
      name: "Task-reviewer",
      description: "Interact with a reviewer subagent",
      parameter_schema: [],
      callback: fn %{state: state} ->
        AgentSupervisor.ensure_started("1", ItMinds.CvAgent.Agents.Reviewer)

        response =
          AgentInstance.send_prompt_sync(
            "1",
            ItMinds.CvAgent.Agents.Reviewer,
            format_project_experience(state)
          )

        {:ok, response}
      end
    )
  end

  defp competency_matcher_agent_tool() do
    Tool.new!(
      name: "match_competencies",
      description: "Extract a list of competencies from the project experience",
      parameter_schema: [],
      callback: fn %{state: state} ->
        AgentSupervisor.ensure_started("1", ItMinds.CvAgent.Agents.CompetencyMatcher)

        _response =
          AgentInstance.send_prompt_sync(
            "1",
            ItMinds.CvAgent.Agents.CompetencyMatcher,
            format_project_experience(state)
          )

        competencies = AgentInstance.get_state("1", ItMinds.CvAgent.Agents.CompetencyMatcher)

        case competencies do
          c when is_list(c) ->
            state_updator = &Map.put(&1, :competencies, c)
            {:set_state, "Succesfully matched competencies", state_updator}

          _ ->
            {:ok, "Extracting competencies failed"}
        end
      end
    )
  end

  defp format_project_experience(%ProjectExperience{} = p) do
    """
    <project-experience>
    # Projekterfaring

    Start dato (måned/år): #{p.start_date}
    Slut dato (måned/år): #{p.end_date}

    ## Kunde

    Kundenavn: #{p.customer_name}
    Projektnavn: #{p.project_name}

    #{p.project_description}

    ## Udviklerens rolle

    Navn på rolle: #{p.employee_role_name}

    #{p.employee_role_description}
    </project-experience>
    """
  end
end
