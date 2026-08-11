defmodule ItMinds.CvAgentWeb.LiveSocketHook do
  @moduledoc """
  Shared LiveView hooks for loading common data like conversations.
  """
  import Phoenix.Component
  alias ItMinds.CvAgent.Conversations

  def on_mount(:default, _params, _session, socket) do
    conversations = Conversations.list_conversations() |> Enum.take(20)

    {:cont, assign(socket, :conversations, conversations)}
  end
end