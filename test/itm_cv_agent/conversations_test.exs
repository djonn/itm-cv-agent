defmodule ItMinds.CvAgent.ConversationsTest do
  use ItMinds.CvAgent.DataCase

  alias ItMinds.CvAgent.Conversations

  describe "conversations" do
    alias ItMinds.CvAgent.Conversations.Conversation

    import ItMinds.CvAgent.ConversationsFixtures

    @invalid_attrs %{name: nil}

    test "list_conversations/0 returns all conversations" do
      conversation = conversation_fixture()
      assert Conversations.list_conversations() == [conversation]
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Conversations.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.create_conversation(valid_attrs)

      assert conversation.name == "some name"
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversations.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.update_conversation(conversation, update_attrs)

      assert conversation.name == "some updated name"
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Conversations.update_conversation(conversation, @invalid_attrs)

      assert conversation == Conversations.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Conversations.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Conversations.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Conversations.change_conversation(conversation)
    end
  end
end
