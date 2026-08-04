defmodule ItMinds.CvAgentWeb.ConversationLive.Index do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.Conversations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Samtaler
        <:actions>
          <.button variant="primary" navigate={~p"/conversations/new"}>
            <.icon name="hero-plus" /> Ny samtale
          </.button>
        </:actions>
      </.header>

      <div :if={@streams.conversations == []} class="flex flex-col items-center justify-center py-20 text-center">
        <div class="max-w-md space-y-4">
          <p class="text-lg font-medium text-base-content">
            Ingen samtaler endnu
          </p>
          <p class="text-base text-base-content/70">
            Start din første samtale om at skrive projekterfaringer.
          </p>
          <.button variant="primary" navigate={~p"/conversations/new"} class="mt-4">
            <.icon name="hero-plus" /> Opret samtale
          </.button>
        </div>
      </div>

      <.table
        :if={@streams.conversations != []}
        id="conversations"
        rows={@streams.conversations}
        row_click={fn {_id, conversation} -> JS.navigate(~p"/conversations/#{conversation}") end}
      >
        <:col :let={{_id, conversation}} label="Navn">{conversation.name}</:col>
        <:action :let={{_id, conversation}}>
          <div class="sr-only">
            <.link navigate={~p"/conversations/#{conversation}"}>Vis</.link>
          </div>
          <.link navigate={~p"/conversations/#{conversation}/edit"}>Redigér</.link>
        </:action>
        <:action :let={{id, conversation}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversation.id}) |> hide("##{id}")}
            data-confirm="Er du sikker?"
            class="text-error hover:text-error/80"
          >
            Slet
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
     |> assign(:page_title, "Samtaler")
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
