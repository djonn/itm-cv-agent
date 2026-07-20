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
      # TODO: Removed while testing for faster answer
      # Context.system(assistant_system_prompt())
    ])
  end

  @assistant_system_prompt File.read!("lib/itm_cv_agent/llm/main-assistant.md")
  @in_danish_prompt File.read!("lib/itm_cv_agent/llm/in-danish.md")

  def assistant_system_prompt(), do: @assistant_system_prompt <> @in_danish_prompt

  @spec setup_tools() :: list(ReqLLM.Tool.t())
  def setup_tools() do
    [
      write_project_experience_tool()
    ]
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
      callback: fn _args -> nil end
    )
  end
end
