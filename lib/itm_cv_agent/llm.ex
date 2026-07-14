defmodule ItMinds.CvAgent.LLM do
  alias ReqLLM.Context

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

  @assistant_system_prompt File.read!("lib/itm_cv_agent/llm/main-assistant.md")
  @in_danish_prompt File.read!("lib/itm_cv_agent/llm/in-danish.md")

  def assistant_system_prompt(), do: @assistant_system_prompt <> @in_danish_prompt
end
