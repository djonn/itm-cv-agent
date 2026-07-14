defmodule ItMinds.CvAgent.ChatAgent do
  use GenServer

  defstruct messages: []

  # Public
  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  def send_prompt(pid) do
    GenServer.call(pid, :inc)
  end

  # Private
  def init(initial) do
    {:ok, initial}
  end

  def handle_call(:inc, _, count) do
    {:reply, count, count + 1}
  end
end
