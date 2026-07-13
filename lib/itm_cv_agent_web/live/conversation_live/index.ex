defmodule ItMinds.CvAgentWeb.ConversationLive.Index do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.Conversations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Conversations
        <:actions>
          <.button variant="primary" navigate={~p"/conversations/new"}>
            <.icon name="hero-plus" /> New Conversation
          </.button>
        </:actions>
      </.header>

      <.table
        id="conversations"
        rows={@streams.conversations}
        row_click={fn {_id, conversation} -> JS.navigate(~p"/conversations/#{conversation}") end}
      >
        <:col :let={{_id, conversation}} label="Name">{conversation.name}</:col>
        <:action :let={{_id, conversation}}>
          <div class="sr-only">
            <.link navigate={~p"/conversations/#{conversation}"}>Show</.link>
          </div>
          <.link navigate={~p"/conversations/#{conversation}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, conversation}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversation.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Conversations")
     |> stream(:conversations, list_conversations())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversation = Conversations.get_conversation!(id)
    {:ok, _} = Conversations.delete_conversation(conversation)

    {:noreply, stream_delete(socket, :conversations, conversation)}
  end

  defp list_conversations() do
    Conversations.list_conversations()
  end
end
