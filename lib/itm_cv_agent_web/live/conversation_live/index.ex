defmodule ItMinds.CvAgentWeb.ConversationLive.Index do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.Conversations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex items-center justify-between gap-4 mb-8">
        <div>
          <h1 class="text-2xl font-bold">Samtaler</h1>
          <p class="text-base-content/70 mt-1">
            Administrer dine samtaler om projekterfaringer
          </p>
        </div>
        <.button
          variant="primary"
          navigate={~p"/conversations/new"}
          class="inline-flex items-center gap-2"
        >
          <.icon name="hero-plus" class="size-5" /> Ny samtale
        </.button>
      </div>

      <div
        :if={@streams.conversations == []}
        class="flex flex-col items-center justify-center py-20 text-center"
      >
        <div class="inline-flex items-center justify-center size-20 rounded-2xl bg-base-200 mb-6">
          <.icon name="hero-chat-bubble-left-right" class="size-10 text-base-content/40" />
        </div>
        <h2 class="text-xl font-semibold mb-2">Ingen samtaler endnu</h2>
        <p class="text-base-content/70 max-w-sm mb-6">
          Start din første samtale om at skrive projekterfaringer. Agenten guider dig gennem processen.
        </p>
        <.button
          variant="primary"
          navigate={~p"/conversations/new"}
          class="inline-flex items-center gap-2"
        >
          <.icon name="hero-plus" class="size-5" /> Opret samtale
        </.button>
      </div>

      <div :if={@streams.conversations != []} class="space-y-4">
        <div
          :for={{id, conversation} <- @streams.conversations}
          id={id}
          class="group relative flex items-center gap-4 rounded-xl border border-base-200 bg-base-100 p-5 hover:border-secondary/50 hover:shadow-md transition-all duration-200"
        >
          <div class="inline-flex items-center justify-center size-12 rounded-xl bg-secondary/10 text-secondary flex-shrink-0">
            <.icon name="hero-chat-bubble-left-right" class="size-6" />
          </div>

          <.link
            navigate={~p"/conversations/#{conversation}"}
            class="flex-1 min-w-0 block group/name"
          >
            <div class="font-semibold text-base group-hover/name:text-secondary transition-colors truncate">
              {conversation.name}
            </div>
            <p class="text-sm text-base-content/60 mt-0.5">
              Oprettet {format_date(conversation.inserted_at)}
            </p>
          </.link>

          <div class="flex items-center gap-2">
            <.link
              navigate={~p"/conversations/#{conversation}/edit"}
              class="inline-flex items-center justify-center size-9 rounded-lg hover:bg-base-200 transition-colors"
              aria-label="Redigér"
              title="Redigér"
            >
              <.icon name="hero-pencil" class="size-4" />
            </.link>
            <.link
              phx-click={JS.push("delete", value: %{id: conversation.id}) |> hide("##{id}")}
              data-confirm="Er du sikker på, at du vil slette denne samtale?"
              class="inline-flex items-center justify-center size-9 rounded-lg hover:bg-error/10 text-error transition-colors"
              aria-label="Slet"
              title="Slet"
            >
              <.icon name="hero-trash" class="size-4" />
            </.link>
          </div>

          <.icon
            name="hero-chevron-right"
            class="size-5 text-base-content/40 group-hover:text-secondary group-hover:translate-x-1 transition-all"
          />
        </div>
      </div>
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

  defp list_conversations do
    Conversations.list_conversations()
  end

  defp format_date(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%d. %b %Y kl. %H:%M")
  end
end
