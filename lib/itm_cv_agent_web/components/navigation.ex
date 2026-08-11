defmodule ItMinds.CvAgentWeb.Navigation do
  @moduledoc """
  Navigation components based on the design system.

  This module provides navigation components including sidebar items,
  conversation list items, and breadcrumbs.

  ## Usage

      <ItMinds.CvAgentWeb.Navigation.sidebar_item navigate={~p"/chats"}>
        <:icon><MaterialIcon.icon name="chat" /></:icon>
        Chats
      </Navigation.sidebar_item>

      <ItMinds.CvAgentWeb.Navigation.conversation_item
        title="Q3 Review"
        timestamp="Today • 2:30 PM"
        active={true}
        navigate={~p"/chat/123"}
      />

      <ItMinds.CvAgentWeb.Navigation.breadcrumbs items={[{"Projects", "/projects"}, {"Design", nil}]} />

  """
  use Phoenix.Component
  alias ItMinds.CvAgentWeb.MaterialIcon

  @doc """
  Sidebar navigation item

  Used for main navigation in sidebar with icon and label.

  ## States
    * Active - Surface container highest background with primary text
    * Inactive - Transparent background with on-surface-variant text, hover state
  """
  attr :navigate, :any, default: nil
  attr :active, :boolean, default: false
  attr :class, :any, default: nil
  slot :icon, required: true
  slot :inner_block, required: true

  def sidebar_item(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "w-full flex items-center gap-3 px-4 py-3 rounded-xl font-interactive text-sm transition-colors",
        @active && "bg-surface-container-highest text-primary",
        !@active && "text-on-surface-variant hover:bg-surface-container hover:text-primary",
        @class
      ]}
    >
      <span class="material-symbols-outlined text-[20px]">
        {render_slot(@icon)}
      </span>
      <span>{render_slot(@inner_block)}</span>
    </.link>
    """
  end

  @doc """
  Conversation list item

  Used for displaying conversation history with title and timestamp.

  ## States
    * Active - Surface container high background
    * Inactive - Transparent background with hover state
  """
  attr :title, :string, required: true
  attr :timestamp, :string, required: true
  attr :active, :boolean, default: false
  attr :navigate, :any, default: nil
  attr :class, :any, default: nil

  def conversation_item(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "px-3 py-3 rounded-xl cursor-pointer transition-colors block",
        @active && "bg-surface-container-high",
        !@active && "hover:bg-surface-container",
        @class
      ]}
    >
      <p class={[
        "text-sm font-interactive truncate",
        @active && "text-primary",
        !@active && "text-on-surface-variant group-hover:text-primary"
      ]}>
        {@title}
      </p>
      <p class={[
        "text-xs mt-1",
        @active && "text-on-surface-variant",
        !@active && "text-on-surface-variant/70"
      ]}>
        {@timestamp}
      </p>
    </.link>
    """
  end

  @doc """
  Breadcrumb navigation

  Used for showing the current page hierarchy.

  ## Examples

      <ItMinds.CvAgentWeb.Navigation.breadcrumbs items={[
        {"Home", "/"},
        {"Conversations", "/conversations"},
        {"Details", nil}
      ]} />

  The last item with nil href is rendered as plain text (current page).
  """
  attr :items, :list, required: true, doc: "List of {label, href} tuples"
  attr :class, :any, default: nil

  def breadcrumbs(assigns) do
    ~H"""
    <nav aria-label="Breadcrumb" class={["flex text-sm font-interactive text-on-surface-variant", @class]}>
      <ol class="inline-flex items-center space-x-1 md:space-x-2">
        <%= for {label, href, index} <- Enum.with_index(@items) do %>
          <%= if index < length(@items) - 1 do %>
            <li class="inline-flex items-center">
              <%= if href do %>
                <.link href={href} class="hover:text-primary transition-colors flex items-center">
                  {label}
                </.link>
              <% else %>
                <span>{label}</span>
              <% end %>
              <%= if index < length(@items) - 1 do %>
                <MaterialIcon.icon name="chevron_right" size="16px" class="mx-1" />
              <% end %>
            </li>
          <% else %>
            <li aria-current="page">
              <div class="flex items-center">
                <MaterialIcon.icon name="chevron_right" size="16px" class="mx-1" />
                <span class="text-primary">{label}</span>
              </div>
            </li>
          <% end %>
        <% end %>
      </ol>
    </nav>
    """
  end

  @doc """
  Navigation bar link

  Used for top navigation bar links.
  """
  attr :navigate, :any, default: nil
  attr :href, :string, default: nil
  attr :active, :boolean, default: false
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      href={@href}
      class={[
        "px-4 py-2 rounded-full font-interactive text-interactive transition-colors",
        "text-on-surface-variant hover:text-primary hover:bg-surface-container",
        @active && "bg-surface-container-highest text-primary",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end