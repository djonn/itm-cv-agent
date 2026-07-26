defmodule ItMinds.CvAgent.LLM do
  alias ReqLLM.{Context, Tool}

  def model() do
    ReqLLM.model!(%{
      provider: :openai,
      id: "google/gemma-4-26b-a4b-it:bf16",
      base_url: "https://api.scaleway.ai/05232108-8415-474e-b3f6-fe485984e92d/v1"
    })
  end

  def new_context() do
    Context.new([
      Context.system(assistant_system_prompt())
    ])
  end

  @type tool_response ::
          {:ok, response :: String.t()}
          | {:ok, {:set_state, response :: String.t(), state_updator :: fun()}}

  @assistant_system_prompt File.read!("lib/itm_cv_agent/llm/main-assistant.md")

  @skill_01_basis_information_prompt File.read!(
                                       "lib/itm_cv_agent/llm/skill-01-basis-information.md"
                                     )
  @skill_02_customer_interview_prompt File.read!(
                                        "lib/itm_cv_agent/llm/skill-02-customer-interview.md"
                                      )
  @skill_03_developer_role_interview_prompt File.read!(
                                              "lib/itm_cv_agent/llm/skill-03-developer-role-interview.md"
                                            )
  @skill_04_review_prompt File.read!("lib/itm_cv_agent/llm/skill-04-review.md")
  @skill_05_match_competencies_prompt File.read!(
                                        "lib/itm_cv_agent/llm/skill-05-match-competencies.md"
                                      )
  @skill_06_english_translation_prompt File.read!(
                                         "lib/itm_cv_agent/llm/skill-06-english-translation.md"
                                       )

  def assistant_system_prompt(), do: @assistant_system_prompt

  @spec setup_tools() :: list(ReqLLM.Tool.t())
  def setup_tools() do
    [
      write_project_experience_tool()
    ] ++ interview_steps_skills()
  end

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
               :customer_name,
               :project_name,
               :project_description,
               :employee_role_name,
               :employee_role_description,
               :competencies,
               :start_date,
               :end_date,
               :employee_name
             ]},
          required: true,
          doc: "What section to write to"
        ],
        language: [
          type: {:in, ["da", "en"]},
          required: false,
          default: :da,
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

  defp interview_steps_skills() do
    [
      {"s01_basis_information", @skill_01_basis_information_prompt},
      {"s02_customer_interview", @skill_02_customer_interview_prompt},
      {"s03_developer_role_interview", @skill_03_developer_role_interview_prompt},
      {"s04_review", @skill_04_review_prompt},
      {"s05_match_competencies", @skill_05_match_competencies_prompt},
      {"s06_english_translation", @skill_06_english_translation_prompt}
    ]
    |> Enum.map(fn {name, prompt} ->
      Tool.new!(
        name: name,
        description: "Brug når Interview struktur siger du skal",
        callback: fn _args -> {:ok, prompt} end
      )
    end)
  end
end
