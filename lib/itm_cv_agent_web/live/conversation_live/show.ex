defmodule ItMinds.CvAgentWeb.ConversationLive.Show do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.{AgentInstance, AgentSupervisor, Conversations}
  alias ItMinds.CvAgent.Agents.Interviewer
  alias ItMinds.CvAgentWeb.Markdown
  alias ItMinds.CvAgentWeb.Layouts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen bg-base-100">
      <header class="navbar px-4 sm:px-6 lg:px-8 fixed top-0 left-0 right-0 bg-base-100/90 backdrop-blur-md border-b border-base-200 z-40 dark:bg-base-100/80 dark:border-base-300">
        <div class="flex-1">
          <a
            href={~p"/conversations"}
            class="flex items-center gap-2 text-base-content/50 hover:text-base-content transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-5" />
            <span class="text-lg font-semibold">{@page_title}</span>
          </a>
        </div>
        <div class="flex-none">
          <ul class="flex flex-column px-1 space-x-4 items-end">
            <li>
              <Layouts.theme_toggle />
            </li>
          </ul>
        </div>
      </header>

      <div class="flex-1 flex flex-col pt-16">
        <div class="flex-1 flex flex-col overflow-hidden">
          <.messages messages={@messages} loading={@loading} streaming_message={@streams.stream} />
        </div>
        <.chat_input form={@form} loading={@loading} />
      </div>

      <Layouts.flash_group flash={@flash} />
    </div>
    """
  end

  attr :messages, :list, required: true, doc: "the list of user and assistant messages"
  attr :loading, :boolean, required: true
  attr :streaming_message, :any, required: true

  defp messages(%{messages: [], loading: false} = assigns) do
    ~H"""
    <div class="flex-1 flex items-center justify-center p-8">
      <div class="text-center max-w-md space-y-4">
        <div class="w-16 h-16 mx-auto rounded-2xl bg-gradient-to-br from-secondary to-amber-600 flex items-center justify-center shadow-lg dark:shadow-none">
          <svg class="w-8 h-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
            />
          </svg>
        </div>
        <h2 class="text-xl font-semibold text-base-content">Start en ny samtale</h2>
        <p class="text-base-content/60">
          Fortæl mig om dit projekt, så hjælper jeg dig med at skrive en stærk projekterfaring.
        </p>
      </div>
    </div>
    """
  end

  defp messages(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto">
      <div class="max-w-3xl mx-auto py-8">
        <div class="space-y-6">
          <.message
            :for={message_envelop <- @messages}
            key={message_envelop.key}
            type={message_envelop.type}
            message={message_envelop.message}
          />
          <.typing_indicator :if={@loading} />
          <div id="stream-parent" phx-update="stream">
            <div
              :for={{dom_id, message} <- @streaming_message}
              id={dom_id}
              class="assistant-message prose prose-sm prose-slate dark:prose-invert max-w-none"
            >
              {raw(message.html)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :message, :string, required: true
  attr :type, :atom, required: true
  attr :key, :string, required: true

  defp message(%{type: :user} = assigns) do
    ~H"""
    <div class="flex justify-end">
      <div class="max-w-[80%] rounded-2xl bg-secondary text-secondary-content px-5 py-3 shadow-sm">
        <p class="text-[15px] leading-relaxed">{@message}</p>
      </div>
    </div>
    """
  end

  defp message(%{type: :assistant} = assigns) do
    ~H"""
    <div class="flex gap-4">
      <div class="flex-shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-secondary to-amber-600 flex items-center justify-center shadow-md dark:shadow-none">
        <svg class="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 10V3L4 14h7v7l9-11h-7z"
          />
        </svg>
      </div>
      <div class="flex-1 min-w-0 pt-1">
        <div class="prose prose-sm prose-slate dark:prose-invert max-w-none text-base-content">
          <Markdown.markdown text={@message} />
        </div>
      </div>
    </div>
    """
  end

  defp typing_indicator(assigns) do
    ~H"""
    <div class="flex gap-4">
      <div class="flex-shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-secondary to-amber-600 flex items-center justify-center shadow-md dark:shadow-none">
        <svg class="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 10V3L4 14h7v7l9-11h-7z"
          />
        </svg>
      </div>
      <div class="flex items-center gap-1.5 pt-2">
        <div class="w-2 h-2 rounded-full bg-secondary/50 animate-bounce" style="animation-delay: 0ms" />
        <div
          class="w-2 h-2 rounded-full bg-secondary/50 animate-bounce"
          style="animation-delay: 150ms"
        />
        <div
          class="w-2 h-2 rounded-full bg-secondary/50 animate-bounce"
          style="animation-delay: 300ms"
        />
      </div>
    </div>
    """
  end

  attr :form, :map, required: true
  attr :loading, :boolean, default: false

  defp chat_input(assigns) do
    ~H"""
    <div class="w-full max-w-3xl mx-auto px-4 pb-6">
      <div class="relative">
        <.form for={@form} id="chat-form" phx-submit="send">
          <div class="relative flex items-end gap-2 bg-base-100 border border-base-200 rounded-2xl p-2 shadow-lg focus-within:ring-2 focus-within:ring-secondary/20 focus-within:border-secondary transition-all dark:shadow-none dark:border-base-300">
            <textarea
              focus
              id={@form[:message].id}
              name={@form[:message].name}
              class="flex-1 resize-none bg-transparent px-4 py-3 text-[15px] text-base-content placeholder:text-base-content/40 outline-none min-h-[52px] max-h-48"
              placeholder="Beskriv dit projekt..."
              phx-hook=".TextAreaSubmitOnEnter"
              disabled={@loading}
              rows="1"
            >{Phoenix.HTML.Form.normalize_value("textarea", @form[:message].value)}</textarea>
            <script :type={Phoenix.LiveView.ColocatedHook} name=".TextAreaSubmitOnEnter">
              export default {
                mounted() {
                  this.el.addEventListener("keydown", e => {
                    if (e.key == "Enter" && !e.shiftKey) {
                      const submitButton = this.el.form.querySelector('button[type="submit"]')
                      if (submitButton.disabled) {
                        return
                      }
                      e.preventDefault();
                      this.el.form.dispatchEvent(
                        new Event("submit", { bubbles: true, cancelable: true })
                      )
                    }
                  })
                  this.el.addEventListener("input", e => {
                    e.target.style.height = "auto"
                    e.target.style.height = Math.min(e.target.scrollHeight, 192) + "px"
                  })
                }
              }
            </script>
            <button
              type="submit"
              class={[
                "flex-shrink-0 rounded-xl p-2.5 transition-all duration-200",
                if(@loading,
                  do: "bg-base-200 text-base-content/30 cursor-not-allowed",
                  else:
                    "bg-secondary text-secondary-content hover:bg-secondary/90 active:scale-95 cursor-pointer shadow-sm"
                )
              ]}
              aria-label={gettext("send")}
              disabled={@loading}
            >
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                />
              </svg>
            </button>
          </div>
        </.form>
        <p class="text-center text-xs text-base-content/40 mt-3">
          AI kan lave fejl. Gennemgå altid indholdet.
        </p>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send", %{"message" => message}, socket) do
    if socket.assigns.loading do
      {:noreply, socket}
    else
      AgentInstance.send_prompt(socket.assigns.conversation.id, Interviewer, message)

      new_messages =
        socket.assigns.messages ++
          [%{type: :user, message: message, key: "latest_user_message"}]

      {
        :noreply,
        socket
        |> assign(:loading, true)
        |> assign(:form, to_form(%{"chat" => ""}))
        |> assign(:messages, new_messages)
      }
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:new_state, new_state}, socket) do
    {
      :noreply,
      socket
      |> assign(:loading, false)
      |> assign(:stream_mdex, MDEx.new(streaming: true))
      |> stream(:stream, [], reset: true)
      |> assign(:messages, context_to_message(new_state.context))
    }
  end

  def handle_info({:update_stream, message}, socket) do
    md_doc = MDEx.Document.put_markdown(socket.assigns.stream_mdex, message.message)
    html_content = MDEx.to_html!(md_doc)

    message = message |> Map.put(:html, html_content) |> Map.put(:id, "streaming")

    {
      :noreply,
      socket
      |> stream_insert(:stream, message)
      |> assign(:stream_mdex, md_doc)
    }
  end

  defp context_to_message(context) do
    context
    |> ReqLLM.Context.to_list()
    |> Enum.filter(&(&1.role in [:user, :assistant]))
    |> Enum.with_index()
    |> Enum.map(fn {message, index} -> format_message(message, index) end)
    |> Enum.reject(&is_nil(&1))
  end

  defp format_message(message, index) do
    try do
      text_part = message.content |> Enum.find(fn part -> part.type == :text end)
      %{type: message.role, message: text_part.text, key: index}
    rescue
      _ ->
        # this was some thinking before calling tools and doesnt have any content to show the user
        nil
    end
  end

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    conversation = Conversations.get_conversation!(id)
    AgentSupervisor.ensure_started(conversation.id, Interviewer)
    {:ok, state} = AgentInstance.get_state(conversation.id, Interviewer)
    AgentInstance.subscribe(conversation.id, Interviewer)

    messages = context_to_message(state.context)

    {:ok,
     socket
     |> assign(:page_title, conversation.name || "Conversation")
     |> assign(:conversation, conversation)
     |> assign(:messages, messages)
     |> assign(:stream_mdex, MDEx.new(streaming: true))
     |> stream(:stream, [])
     |> assign(:loading, false)
     |> assign(:form, to_form(%{"chat" => ""}))}
  end
end
