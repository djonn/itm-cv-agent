defmodule ItMinds.CvAgent.ConversationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ItMinds.CvAgent.Conversations` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ItMinds.CvAgent.Conversations.create_conversation()

    conversation
  end
end
