defmodule ItMinds.CvAgent.Agents.Translator do
  alias ReqLLM.{Context, Tool}
  alias ItMinds.CvAgent.ProjectExperience

  @behaviour ItMinds.CvAgent.Agents.Behaviour

  @translatable_sections ~W"project_name project_description employee_role_name employee_role_description"

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
      Context.system(translator_system_prompt())
    ])
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def new_state() do
    %{
      "en" => %ProjectExperience{},
      "da" => %ProjectExperience{}
    }
  end

  @impl ItMinds.CvAgent.Agents.Behaviour
  def setup_tools(_state) do
    [
      write_english_translation(),
      read_original_danish()
    ]
  end

  defp write_english_translation() do
    Tool.new!(
      name: "write_english_translation",
      description: "Write a segment of the project experience",
      parameter_schema: [
        section: [
          type: {:in, @translatable_sections},
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
        state_updator = fn state ->
          updated_translation =
            state
            |> Map.get("en")
            |> Map.put(section |> String.to_atom(), value)

          state |> Map.put("en", updated_translation)
        end

        {:set_state, "Succesfully updated translation", state_updator}
      end
    )
  end

  defp read_original_danish() do
    Tool.new!(
      name: "read_original_danish",
      description: "Read a segment of the original danish project experience",
      parameter_schema: [
        section: [
          type: {:in, @translatable_sections},
          required: true,
          doc: "What section to read"
        ]
      ],
      callback: fn %{state: state, section: section} ->
        section_content = state |> Map.get("da") |> Map.get(section |> String.to_atom(), "")
        {:ok, section_content}
      end
    )
  end

  @translator_system_prompt File.read!("lib/itm_cv_agent/llm/translator-agent.md")

  defp translator_system_prompt(), do: @translator_system_prompt
end
