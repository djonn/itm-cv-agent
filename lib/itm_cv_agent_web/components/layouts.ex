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
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="border-b border-outline-variant/20 bg-surface">
      <div class="max-w-container-max mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-primary-container text-on-primary flex items-center justify-center shadow-md">
              <MaterialIcon.icon name="auto_awesome" size="24px" />
            </div>
            <span class="font-display-lg text-xl font-bold text-primary">CV Agent</span>
          </div>
          <div class="flex items-center gap-4">
            <nav class="hidden md:flex items-center gap-2">
              <Navigation.nav_link navigate={~p"/"}>Home</Navigation.nav_link>
              <Navigation.nav_link navigate={~p"/conversations"}>Conversations</Navigation.nav_link>
              <Navigation.nav_link navigate={~p"/design-system"}>Design System</Navigation.nav_link>
            </nav>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-container-max mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

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