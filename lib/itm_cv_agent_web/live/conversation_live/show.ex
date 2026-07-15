defmodule ItMinds.CvAgentWeb.ConversationLive.Show do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.{AgentInstance, AgentSupervisor, Conversations}
  alias ItMinds.CvAgentWeb.Markdown

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="w-full h-[calc(100dvh-64px)] flex flex-col ">
        <.messages messages={@messages} loading={@loading} streaming_message={@streams.stream} />
        <%!-- <.stream_message :if={not @loading} stream={@streams.stream} /> --%>
        <.chat_input form={@form} />
      </div>
    </Layouts.app>
    """
  end

  attr :messages, :list, required: true, doc: "the list of user and assistant messages"
  attr :loading, :boolean, required: true
  attr :streaming_message, :any, required: true

  defp messages(%{messages: [], loading: false} = assigns) do
    ~H"""
    <div>
      <div class="h-[50dvh]" />
      <p>
        To get started why don't you tell me about the project?
      </p>
    </div>
    """
  end

  defp messages(assigns) do
    ~H"""
    <div class="h-[calc(100dvh-64px-126px)] overflow-auto scrollbar-none">
      <div class="flex flex-col-reverse">
        <%!-- NOTE: Elements are reversed so we scroll to bottom automatically --%>
        <div class="h-[64px]" />
        <div :if={@loading}>
          <p>Loading...</p>
        </div>
        <.streaming_message
          :if={@loading}
          streaming_message={@streaming_message}
        />
        <.message
          :for={message_envelop <- @messages |> Enum.reverse()}
          type={message_envelop.type}
          message={message_envelop.message}
        />
      </div>
    </div>
    """
  end

  attr :message, :string, required: true
  attr :type, :atom, required: true

  defp message(%{type: :user} = assigns) do
    ~H"""
    <div class="flex flex-row justify-end py-5">
      <p class="rounded-full bg-slate-200 dark:bg-slate-800 px-4 py-2">{@message}</p>
    </div>
    """
  end

  defp message(%{type: :assistant} = assigns) do
    ~H"""
    <div class="flex flex-row justify-start py-5">
      <div><Markdown.markdown text={@message} /></div>
    </div>
    """
  end

  attr :streaming_message, :any, required: true

  defp streaming_message(assigns) do
    ~H"""
    <div class="flex flex-row justify-start py-5">
      <p id="stream-parent" phx-update="stream">
        <span :for={{dom_id, message} <- @streaming_message} id={dom_id}>{message.message}</span>
      </p>
    </div>
    """
  end

  attr :form, :map, required: true

  defp chat_input(assigns) do
    ~H"""
    <div class="w-full flex flex-row justify-center py-8">
      <div class="w-7/8 rounded-3xl bg-white dark:bg-black p-2">
        <.form for={@form} id="chat-form" phx-submit="send" class="flex flex-row">
          <textarea
            focus
            id={@form[:message].id}
            name={@form[:message].name}
            class="flex-grow resize-none field-sizing-content bg-transparent px-4 py-2 outline-none focus:ring-0"
            placeholder="Say a few words about the project.."
            phx-hook=".TextAreaSubmitOnEnter"
          >{Phoenix.HTML.Form.normalize_value("textarea", @form[:message].value)}</textarea>
          <script :type={Phoenix.LiveView.ColocatedHook} name=".TextAreaSubmitOnEnter">
            export default {
              mounted() {
                this.el.addEventListener("keydown", e => {
                  if (e.key == "Enter" && !e.shiftKey) {
                    e.preventDefault();
                    this.el.form.dispatchEvent(
                      new Event("submit", { bubbles: true, cancelable: true })
                    )
                  }
                })
              }
            }
          </script>
          <button
            type="submit"
            class="flex flex-col justify-around pr-3 cursor-pointer"
            aria-label={gettext("close")}
          >
            <.icon name="hero-paper-airplane" class="size-5" />
          </button>
        </.form>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send", %{"message" => message}, socket) do
    :ok = AgentInstance.send_prompt(socket.assigns.conversation.id, message)

    {
      :noreply,
      socket
      |> assign(:loading, true)
      |> assign(:form, to_form(%{"chat" => ""}))
    }
  end

  @impl Phoenix.LiveView
  def handle_info({:new_state, new_state}, socket) do
    {
      :noreply,
      socket
      |> assign(:loading, false)
      |> stream(:stream, [], reset: true)
      |> assign(:messages, context_to_message(new_state.context))
    }
  end

  def handle_info({:update_stream, message}, socket) do
    {:noreply, stream_insert(socket, :stream, message)}
  end

  defp context_to_message(context) do
    context
    |> ReqLLM.Context.to_list()
    |> Enum.filter(&(&1.role in [:user, :assistant]))
    |> Enum.flat_map(fn message ->
      message.content |> Enum.map(&%{message: message, content_part: &1})
    end)
    |> Enum.filter(&(&1.content_part.type == :text))
    |> Enum.map(&%{type: &1.message.role, message: &1.content_part.text})
  end

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    conversation = Conversations.get_conversation!(id)
    AgentSupervisor.ensure_started(conversation.id, AgentInstance)
    {:ok, state} = AgentInstance.get_state(conversation.id)
    AgentInstance.subscribe(conversation.id, AgentInstance)

    messages = context_to_message(state.context)

    {:ok,
     socket
     |> assign(:page_title, conversation.name || "Conversation")
     |> assign(:conversation, conversation)
     |> assign(:messages, messages)
     |> stream(:stream, [])
     |> assign(:loading, false)
     |> assign(:form, to_form(%{"chat" => ""}))}
  end
end
