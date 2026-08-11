defmodule ItMinds.CvAgentWeb.ChatLive do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.{AgentInstance, AgentSupervisor, Conversations}
  alias ItMinds.CvAgent.Agents.Interviewer

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} conversations={@conversations} current_path={@current_path}>
      <div class="flex flex-col h-[calc(100vh-4rem)]">
        <!-- Chat Messages -->
        <div id="chat-messages" class="flex-1 overflow-y-auto py-6 space-y-6 mb-20 flex flex-col-reverse">
          <div class="max-w-3xl mx-auto px-8 space-y-6">
            <div :if={@messages == [] && !@loading} class="flex flex-col items-center justify-center h-[50dvh] text-center">
              <img src="/images/cv_chat_bubble.avif" alt="CV Assistant" class="w-72 h-auto max-w-full mb-8" />
              <Typography.body_large class="mb-6">
                Jeg er her for at hjælpe dig med at skabe en overbevisende CV-historie.
              </Typography.body_large>
              <div class="space-y-2 text-left">
                <Typography.body_medium class="flex items-center gap-2">
                  <span class="text-primary">•</span>
                  Et projekt du har arbejdet på
                </Typography.body_medium>
                <Typography.body_medium class="flex items-center gap-2">
                  <span class="text-primary">•</span>
                  En rolle du vil beskrive
                </Typography.body_medium>
                <Typography.body_medium class="flex items-center gap-2">
                  <span class="text-primary">•</span>
                  Copy-paste direkte fra Flowcase
                </Typography.body_medium>
              </div>
            </div>
          <%= for message <- @messages do %>
            <div id={"message-#{message.key}"} class={"flex gap-4 #{if message.role == :user, do: "flex-row-reverse", else: ""}"}>
              <!-- Message Content -->
              <div class={[message.role == :user && "max-w-[80%] ml-auto",
                message.role == :assistant && "w-full"
              ]}>
                <div class={["rounded-2xl px-4 py-3",
                  message.role == :user && "bg-primary-container text-on-primary",
                  message.role == :assistant && "bg-transparent text-on-surface"
                ]}>
                  <ItMinds.CvAgentWeb.Markdown.markdown text={message.content} />
                </div>
              </div>
            </div>
          <% end %>
          <div id="stream-parent" phx-update="stream" class={[
            "flex flex-row justify-start py-5",
            @loading || "hidden"
          ]}>
            <div :for={{dom_id, message} <- @streams.stream} id={dom_id}>
              <div class="flex gap-4">
                <div class="w-full">
                  <div class="rounded-2xl px-4 py-3 bg-transparent text-on-surface">
                    {raw(message.html)}
                  </div>
                </div>
              </div>
            </div>
          </div>
          </div>
        </div>

        <!-- Chat Input -->
        <div class="fixed bottom-0 left-72 right-0 bg-background border-t border-outline-variant/10 pt-4 pb-2">
          <div class="max-w-3xl mx-auto px-8">
            <.form for={@form} id="chat-form" phx-submit="send">
              <ItMinds.CvAgentWeb.Input.prompt
                id="chat-input"
                name="chat"
                value={@form[:chat].value || ""}
                placeholder="Message..."
                phx-hook=".TextAreaSubmitOnEnter"
                show_attachments={false}
                show_image={false}
                show_send={true}
                send_disabled={@loading || String.trim(@form[:chat].value || "") == ""}
              />
            </.form>
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
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    conversation = Conversations.get_conversation!(id)
    AgentSupervisor.ensure_started(conversation.id, Interviewer)
    {:ok, state} = AgentInstance.get_state(conversation.id, Interviewer)
    AgentInstance.subscribe(conversation.id, Interviewer)

    messages = context_to_message(state.context)
    conversations = Conversations.list_conversations() |> Enum.take(20)

    {:ok,
     socket
     |> assign(:page_title, conversation.name || "Chat")
     |> assign(:conversation, conversation)
     |> assign(:messages, messages)
     |> assign(:stream_mdex, MDEx.new(streaming: true))
     |> stream(:stream, [])
     |> assign(:loading, false)
     |> assign(:form, to_form(%{"chat" => ""}))
     |> assign(:conversations, conversations)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign_current_path(socket, url)}
  end

  @impl true
  def handle_event("send", %{"chat" => message}, socket) do
    if socket.assigns.loading do
      {:noreply, socket}
    else
      AgentInstance.send_prompt(socket.assigns.conversation.id, Interviewer, message)

      new_messages =
        socket.assigns.messages ++
          [%{role: :user, content: message, key: "latest_user_message"}]

      {
        :noreply,
        socket
        |> assign(:loading, true)
        |> assign(:form, to_form(%{"chat" => ""}))
        |> assign(:messages, new_messages)
      }
    end
  end

  @impl true
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
    if not socket.assigns.loading do
      {:noreply, socket}
    else
      md_doc = MDEx.Document.put_markdown(socket.assigns.stream_mdex, message.message)
      html_content = MDEx.to_html!(md_doc)

      message = %{html: html_content, id: "streaming"}

      {
        :noreply,
        socket
        |> stream_insert(:stream, message, at: -1, limit: 1)
        |> assign(:stream_mdex, md_doc)
      }
    end
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
      %{role: message.role, content: text_part.text, key: index}
    rescue
      _ ->
        nil
    end
  end

  defp assign_current_path(socket, url) do
    uri = URI.parse(url)
    assign(socket, :current_path, uri.path)
  end
end
