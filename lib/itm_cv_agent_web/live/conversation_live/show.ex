defmodule ItMinds.CvAgentWeb.ConversationLive.Show do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.Conversations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="w-full h-[calc(100dvh-64px)] flex flex-col ">
        <.messages messages={@messages} />
        <.chat_input form={@form} />
      </div>
    </Layouts.app>
    """
  end

  attr :messages, :list, required: true, doc: "the list of user and assistant messages"

  defp messages(%{messages: []} = assigns) do
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
        <div class="h-[64px]" />
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
      <p>{@message}</p>
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
          <button type="submit" class="flex flex-col justify-around pr-3 cursor-pointer" aria-label={gettext("close")}>
            <.icon name="hero-paper-airplane" class="size-5" />
          </button>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    # TODO:
    dbg(message)

    {
      :noreply,
      socket
      |> assign(:messages, socket.assigns.messages ++ [%{type: :user, message: message}, %{type: :assistant, message: "Hello Jonas, how can I help you today?"}])
      |> assign(:form, to_form(%{"chat" => ""}))
    }
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    conversation = Conversations.get_conversation!(id)

    {:ok,
     socket
     |> assign(:page_title, conversation.name || "Conversation")
     |> assign(:conversation, conversation)
     |> assign(:messages, [])
     |> assign(:form, to_form(%{"chat" => ""}))}
  end
end
