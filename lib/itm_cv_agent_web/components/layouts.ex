defmodule ItMinds.CvAgentWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ItMinds.CvAgentWeb, :html


  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout with sidebar navigation.

  This function is typically invoked from every template,
  and it contains the sidebar with conversation list.

  ## Examples

      <Layouts.app flash={@flash} conversations={@conversations} current_path={@current_path}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :conversations, :list, default: [], doc: "list of conversations for the sidebar"
  attr :current_path, :string, default: "/", doc: "the current path for highlighting active nav items"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div id="sidebar-wrapper" class="flex min-h-screen bg-background ds-grid">
      <!-- Sidebar -->
      <aside
        id="sidebar"
        class="w-72 bg-surface border-r border-outline-variant/10 flex flex-col fixed h-full transition-transform duration-300"
      >
        <!-- Logo & Toggle -->
        <div class="p-4 border-b border-outline-variant/10 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-primary-container text-on-primary flex items-center justify-center shadow-md">
              <MaterialIcon.icon name="auto_awesome" size="24px" />
            </div>
            <span class="font-display-lg text-xl font-bold text-primary">CV Agent</span>
          </div>
          <button
            id="sidebar-toggle"
            phx-click={toggle_sidebar()}
            class="p-2 rounded-lg hover:bg-surface-container text-on-surface-variant"
            aria-label="Toggle sidebar"
          >
            <MaterialIcon.icon name="keyboard_double_arrow_left" size="20px" />
          </button>
        </div>

        <!-- New Conversation Button -->
        <div class="p-4">
          <.button variant="primary" navigate={~p"/conversations/new"} class="w-full justify-center">
            <MaterialIcon.icon name="add" size="18px" />
            New Conversation
          </.button>
        </div>

        <!-- Conversation List -->
        <div class="flex-1 overflow-y-auto p-2">
          <p class="text-xs font-interactive text-on-surface-variant uppercase tracking-wider px-3 py-2">
            Recent Conversations
          </p>
          <div class="space-y-1">
            <%= for conversation <- @conversations do %>
              <Navigation.conversation_item
                title={conversation.name || "Untitled"}
                timestamp={format_timestamp(conversation)}
                active={@current_path =~ ~r"^/conversations/#{conversation.id}"}
                navigate={~p"/conversations/#{conversation}"}
              />
            <% end %>
          </div>
        </div>
      </aside>

      <!-- Main Content -->
      <main id="main-content" class="flex-1 ml-72 transition-all duration-300">
        <button
          id="sidebar-open"
          phx-click={toggle_sidebar()}
          class="fixed top-4 left-4 z-50 p-2 rounded-lg bg-surface shadow-md hover:bg-surface-container text-on-surface-variant"
          aria-label="Open sidebar"
        >
          <MaterialIcon.icon name="menu" size="24px" />
        </button>
        <div class="max-w-container-max mx-auto px-8 py-8">
          <div class="space-y-4">
            {render_slot(@inner_block)}
          </div>
        </div>
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  defp toggle_sidebar do
    JS.toggle_class("sidebar-closed", to: "#sidebar-wrapper")
  end

  defp format_timestamp(%{inserted_at: %DateTime{} = inserted_at}) do
    cond do
      DateTime.diff(DateTime.utc_now(), inserted_at, :day) == 0 ->
        "Today • " <> Calendar.strftime(inserted_at, "%H:%M")

      DateTime.diff(DateTime.utc_now(), inserted_at, :day) == 1 ->
        "Yesterday"

      DateTime.diff(DateTime.utc_now(), inserted_at, :day) <= 7 ->
        "Previous 7 Days"

      true ->
        Calendar.strftime(inserted_at, "%b %d, %Y")
    end
  end

  defp format_timestamp(_), do: ""

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <MaterialIcon.icon name="refresh" size="16px" class="ml-1 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <MaterialIcon.icon name="refresh" size="16px" class="ml-1 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end