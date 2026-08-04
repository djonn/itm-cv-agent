defmodule ItMinds.CvAgentWeb.ConversationLive.Form do
  use ItMinds.CvAgentWeb, :live_view

  alias ItMinds.CvAgent.Conversations
  alias ItMinds.CvAgent.Conversations.Conversation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Administrér samtaler i din database.</:subtitle>
      </.header>

      <.form for={@form} id="conversation-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Navn" />
        <footer class="mt-6 flex gap-4">
          <.button phx-disable-with="Gemmer..." variant="primary">Gem samtale</.button>
          <.button navigate={return_path(@return_to, @conversation)}>Annullér</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    conversation = Conversations.get_conversation!(id)

    socket
    |> assign(:page_title, "Redigér samtale")
    |> assign(:conversation, conversation)
    |> assign(:form, to_form(Conversations.change_conversation(conversation)))
  end

  defp apply_action(socket, :new, _params) do
    conversation = %Conversation{}

    socket
    |> assign(:page_title, "Ny samtale")
    |> assign(:conversation, conversation)
    |> assign(:form, to_form(Conversations.change_conversation(conversation)))
  end

  @impl true
  def handle_event("validate", %{"conversation" => conversation_params}, socket) do
    changeset =
      Conversations.change_conversation(socket.assigns.conversation, conversation_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversation" => conversation_params}, socket) do
    save_conversation(socket, socket.assigns.live_action, conversation_params)
  end

  defp save_conversation(socket, :edit, conversation_params) do
    case Conversations.update_conversation(socket.assigns.conversation, conversation_params) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Samtale opdateret")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversation(socket, :new, conversation_params) do
    case Conversations.create_conversation(conversation_params) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Samtale oprettet")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _conversation), do: ~p"/conversations"
  defp return_path("show", conversation), do: ~p"/conversations/#{conversation}"
end
