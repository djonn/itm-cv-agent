defmodule ItMinds.CvAgent.LLM do

  def model() do
    ReqLLM.model!(%{
      provider: :openai,
      id: "google/gemma-4-26b-a4b-it:bf16",
      base_url: "https://api.scaleway.ai/05232108-8415-474e-b3f6-fe485984e92d/v1",
    })
  end

end
