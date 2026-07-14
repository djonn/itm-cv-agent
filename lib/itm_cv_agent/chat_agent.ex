defmodule ItMinds.CvAgent.ChatAgent do
  use GenServer

  alias ItMinds.CvAgent.LLM
  alias ItMinds.CvAgent.ProjectExperience

  defstruct [:phase, :context, :project_experience]

  @type t :: %__MODULE__{
          phase: :setup | :customer_interview | :developer_role_interview | :review | :competency_matching | :translation,
          context: ReqLLM.Context.t(),
          project_experience: ProjectExperience.t()
        }

  # Public
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def send_prompt(pid) do
    GenServer.call(pid, :inc)
  end

  # Private
  def init(_initial) do
    {:ok, %__MODULE__{phase: :setup, context: LLM.new_context(), project_experience: %ProjectExperience{}}}
  end

  def handle_call(:inc, _, count) do
    {:reply, count, count + 1}
  end
end
