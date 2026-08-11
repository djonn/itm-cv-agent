defmodule ItMinds.CvAgentWeb.Content do
  @moduledoc """
  Content display components based on the design system.

  This module provides components for displaying content including avatars,
  content cards, and chat messages.

  ## Usage

      <ItMinds.CvAgentWeb.Content.avatar type="ai" />
      <ItMinds.CvAgentWeb.Content.avatar type="user" initials="JD" />
      <ItMinds.CvAgentWeb.Content.avatar type="user" image_url={@user.avatar_url} />

      <ItMinds.CvAgentWeb.Content.content_card
        title="Executive Summary.md"
        timestamp="Generated 2 mins ago"
        content={@summary}
      />

      <ItMinds.CvAgentWeb.Content.chat_message type="user">Can you help me?</Content.chat_message>
      <ItMinds.CvAgentWeb.Content.chat_message type="ai">Of course!</Content.chat_message>

  """
  use Phoenix.Component
  alias ItMinds.CvAgentWeb.MaterialIcon

  @doc """
  Avatar component for AI assistants or users

  ## Types
    * `:ai` - AI assistant avatar with icon
    * `:user` - User avatar with image or initials
  """
  attr :type, :string, values: ~w(ai user), required: true
  attr :size, :string, values: ~w(sm md lg), default: "md"
  attr :image_url, :string, default: nil
  attr :initials, :string, default: nil
  attr :icon, :string, default: "auto_awesome"
  attr :class, :any, default: nil

  def avatar(assigns) do
    size_classes =
      case assigns[:size] do
        "sm" -> "w-8 h-8"
        "md" -> "w-10 h-10"
        "lg" -> "w-12 h-12"
      end

    icon_size =
      case assigns[:size] do
        "sm" -> "16px"
        "md" -> "20px"
        "lg" -> "24px"
      end

    assigns = assign(assigns, :size_classes, size_classes)
    assigns = assign(assigns, :icon_size, icon_size)

    ~H"""
    <div
      :if={@type == "ai"}
      class={[
        "rounded-full flex items-center justify-center shadow-sm shrink-0",
        @size == "lg" && "w-12 h-12 bg-primary-container text-on-primary shadow-md",
        @size == "md" && "w-10 h-10 bg-primary-container text-on-primary shadow-sm",
        @size == "sm" && "w-8 h-8 bg-primary-container text-on-primary shadow-sm",
        @class
      ]}
    >
      <MaterialIcon.icon name={@icon} size={@icon_size} />
    </div>

    <div
      :if={@type == "user" && @image_url}
      class={[
        "rounded-full object-cover shadow-sm",
        @size_classes,
        @class
      ]}
      src={@image_url}
      alt="User avatar"
    />

    <div
      :if={@type == "user" && !@image_url}
      class={[
        "rounded-full flex items-center justify-center font-interactive shadow-sm",
        @size == "lg" && "w-12 h-12 bg-secondary/10 text-secondary border border-secondary/20",
        @size == "md" && "w-10 h-10 bg-secondary/10 text-secondary border border-secondary/20",
        @size == "sm" && "w-8 h-8 bg-secondary/10 text-secondary border border-secondary/20",
        @class
      ]}
    >
      {@initials || "U"}
    </div>
    """
  end

  @doc """
  Content card for AI-generated content

  Displays generated content with metadata and actions.
  """
  attr :title, :string, required: true
  attr :timestamp, :string, default: nil
  attr :content, :string, default: nil
  attr :format, :string, default: nil
  attr :size, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :actions

  def content_card(assigns) do
    ~H"""
    <div
      class={[
        "bg-surface p-6 rounded-[24px] border border-outline-variant/15 shadow-sm hover:shadow-md transition-shadow group",
        @class
      ]}
      {@rest}
    >
      <div class="flex justify-between items-start mb-4">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-full bg-primary-container text-on-primary flex items-center justify-center shadow-sm shrink-0">
            <MaterialIcon.icon name="insert_drive_file" size="16px" />
          </div>
          <div>
            <h4 class="font-interactive text-primary text-base">{@title}</h4>
            <p :if={@timestamp} class="text-xs text-on-surface-variant">{@timestamp}</p>
          </div>
        </div>
        <div :if={@actions != []} class="opacity-0 group-hover:opacity-100 transition-opacity flex gap-2">
          {render_slot(@actions)}
        </div>
      </div>

      <div :if={@content} class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/10">
        <p class="font-body-md text-sm text-on-surface-variant line-clamp-3">
          {@content}
        </p>
      </div>

      <div :if={@format || @size} class="mt-4 flex gap-2">
        <span :if={@format} class="px-2.5 py-1 bg-surface-container-high text-primary text-[11px] font-interactive rounded-md">
          {@format}
        </span>
        <span :if={@size} class="px-2.5 py-1 bg-surface-container-high text-primary text-[11px] font-interactive rounded-md">
          {@size}
        </span>
      </div>
    </div>
    """
  end

  @doc """
  Chat message bubble

  Displays user or AI messages in chat interface.
  """
  attr :type, :string, values: ~w(user ai), required: true
  attr :avatar_url, :string, default: nil
  attr :timestamp, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true
  slot :actions

  def chat_message(assigns) do
    ~H"""
    <div
      :if={@type == "user"}
      class="flex items-end justify-end gap-3 w-full max-w-2xl ml-auto"
    >
      <div class="relative group">
        <div class="bg-surface p-4 rounded-3xl rounded-br-sm shadow-sm border border-outline-variant/10">
          {render_slot(@inner_block)}
        </div>
        <div :if={@timestamp} class="text-xs text-on-surface-variant mt-1 text-right">
          {@timestamp}
        </div>
        <div :if={@actions != []} class="absolute top-2 -left-10 opacity-0 group-hover:opacity-100 transition-opacity">
          {render_slot(@actions)}
        </div>
      </div>
      <ItMinds.CvAgentWeb.Content.avatar type="user" size="sm" image_url={@avatar_url} />
    </div>

    <div
      :if={@type == "ai"}
      class="flex items-start gap-3 w-full max-w-3xl"
    >
      <ItMinds.CvAgentWeb.Content.avatar type="ai" size="md" />
      <div class="relative group flex-1">
        <div class="bg-transparent p-4 rounded-3xl border-l-4 border-surface-container-high bg-surface-container-lowest shadow-sm">
          {render_slot(@inner_block)}
        </div>
        <div :if={@timestamp} class="text-xs text-on-surface-variant mt-1">
          {@timestamp}
        </div>
        <div
          :if={@actions != []}
          class="flex gap-2 mt-4 pt-3 border-t border-outline-variant/10 opacity-0 group-hover:opacity-100 transition-opacity"
        >
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Chat message action buttons

  Provides common actions for chat messages (copy, regenerate, thumbs up/down).
  """
  attr :show_copy, :boolean, default: true
  attr :show_regenerate, :boolean, default: true
  attr :show_feedback, :boolean, default: true
  attr :class, :any, default: nil

  attr :on_copy, :string, default: nil, doc: "phx-click event for copy button"
  attr :on_regenerate, :string, default: nil, doc: "phx-click event for regenerate button"
  attr :on_thumbs_up, :string, default: nil, doc: "phx-click event for thumbs up"
  attr :on_thumbs_down, :string, default: nil, doc: "phx-click event for thumbs down"

  def chat_actions(assigns) do
    ~H"""
    <div class={["flex gap-2", @class]}>
      <button
        :if={@show_copy}
        type="button"
        phx-click={@on_copy}
        class="text-on-surface-variant hover:text-primary p-1.5 rounded-lg hover:bg-surface-container transition-colors"
        title="Copy"
      >
        <MaterialIcon.icon name="content_copy" size="18px" />
      </button>
      <button
        :if={@show_regenerate}
        type="button"
        phx-click={@on_regenerate}
        class="text-on-surface-variant hover:text-primary p-1.5 rounded-lg hover:bg-surface-container transition-colors"
        title="Regenerate"
      >
        <MaterialIcon.icon name="refresh" size="18px" />
      </button>
      <div :if={@show_feedback} class="flex gap-2 ml-auto">
        <button
          type="button"
          phx-click={@on_thumbs_up}
          class="text-on-surface-variant hover:text-primary p-1.5 rounded-lg hover:bg-surface-container transition-colors"
          title="Good response"
        >
          <MaterialIcon.icon name="thumb_up" size="18px" />
        </button>
        <button
          type="button"
          phx-click={@on_thumbs_down}
          class="text-on-surface-variant hover:text-primary p-1.5 rounded-lg hover:bg-surface-container transition-colors"
          title="Bad response"
        >
          <MaterialIcon.icon name="thumb_down" size="18px" />
        </button>
      </div>
    </div>
    """
  end
end