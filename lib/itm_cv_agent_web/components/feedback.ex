defmodule ItMinds.CvAgentWeb.Feedback do
  @moduledoc """
  Feedback and status components based on the design system.

  This module provides components for user feedback including loading states,
  chips, tooltips, status indicators, and notifications.

  ## Usage

      <Feedback.typing_indicator />
      <Feedback.chip>AI Generated</Feedback.chip>
      <Feedback.tooltip text="Model information">
        <:trigger><MaterialIcon.icon name="info" /></:trigger>
      </Feedback.tooltip>
      <Feedback.status_indicator status="active">System Operational</Feedback.status_indicator>
      <Feedback.toast>Draft saved</Feedback.toast>

  """
  use Phoenix.Component
  alias ItMinds.CvAgentWeb.MaterialIcon

  @doc """
  Typing indicator with animated dots

  Used to show AI is generating a response.
  """
  attr :class, :any, default: nil
  attr :dot_count, :integer, default: 3
  attr :dot_size, :string, default: "w-1.5 h-1.5"
  attr :color, :string, default: "bg-primary-container"

  def typing_indicator(assigns) do
    ~H"""
    <div class={["bg-surface-container-low p-4 rounded-2xl w-max shadow-sm border border-outline-variant/5", @class]}>
      <div class="flex gap-1.5 items-center justify-center h-4">
        <%= for i <- 0..(@dot_count - 1) do %>
          <div
            class={[
              @dot_size,
              @color,
              "rounded-full animate-bounce"
            ]}
            style={"animation-delay: #{i * 150}ms"}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Chip/tag component for labels and status

  Used for categorization, status badges, or metadata display.

  ## Variants
    * `:default` - Surface container high background
    * `:ai` - Secondary color with light background (AI Generated)
    * `:draft` - Primary container with light background
    * `:custom` - Custom classes
  """
  attr :variant, :string, values: ~w(default ai draft custom), default: "default"
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def chip(assigns) do
    variant_classes =
      case assigns[:variant] do
        "default" ->
          "bg-surface-container-high text-primary border-outline-variant/20"

        "ai" ->
          "bg-secondary/10 text-secondary border-secondary/20"

        "draft" ->
          "bg-primary-container/10 text-primary-container border-primary-container/20"

        "custom" ->
          ""

        _ ->
          "bg-surface-container-high text-primary border-outline-variant/20"
      end

    assigns = assign(assigns, :variant_classes, variant_classes)

    ~H"""
    <span
      class={[
        "px-3 py-1 text-xs font-interactive rounded-lg border",
        @variant_classes,
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Tooltip with info icon

  Used to show additional information on hover.
  """
  attr :text, :string, required: true
  attr :position, :string, values: ~w(top bottom left right), default: "top"
  attr :class, :any, default: nil
  slot :trigger

  def tooltip(assigns) do
    position_classes =
      case assigns[:position] do
        "top" -> "bottom-full mb-2 -translate-x-1/2 left-1/2 after:top-full after:left-1/2 after:-translate-x-1/2 after:-mt-1 after:border-4 after:border-transparent after:border-t-inverse-surface"
        "bottom" -> "top-full mt-2 -translate-x-1/2 left-1/2 after:bottom-full after:left-1/2 after:-translate-x-1/2 after:-mb-1 after:border-4 after:border-transparent after:border-b-inverse-surface"
        "left" -> "right-full mr-2 -translate-y-1/2 top-1/2 after:left-full after:top-1/2 after:-translate-y-1/2 after:-ml-1 after:border-4 after:border-transparent after:border-l-inverse-surface"
        "right" -> "left-full ml-2 -translate-y-1/2 top-1/2 after:right-full after:top-1/2 after:-translate-y-1/2 after:-mr-1 after:border-4 after:border-transparent after:border-r-inverse-surface"
      end

    assigns = assign(assigns, :position_classes, position_classes)

    ~H"""
    <div class={["relative group cursor-help inline-block", @class]}>
      <%= if @trigger != [] do %>
        {render_slot(@trigger)}
      <% else %>
        <MaterialIcon.icon name="info" size="20px" class="text-on-surface-variant" />
      <% end %>
      <div
        class={[
          "absolute px-3 py-2 bg-inverse-surface text-inverse-on-surface text-xs rounded-lg whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity z-10 shadow-lg font-body-md pointer-events-none",
          @position_classes
        ]}
      >
        {@text}
      </div>
    </div>
    """
  end

  @doc """
  Status indicator with colored dot

  Used to show system status or availability.

  ## Status colors
    * `:active` - Green
    * `:inactive` - Gray
    * `:error` - Red
    * `:warning` - Yellow/Orange
  """
  attr :status, :string, default: "active"
  attr :label, :string, default: nil
  attr :class, :any, default: nil

  def status_indicator(assigns) do
    status_color =
      case assigns[:status] do
        "active" -> "bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]"
        "inactive" -> "bg-outline-variant"
        "error" -> "bg-error shadow-[0_0_8px_rgba(186,26,26,0.4)]"
        "warning" -> "bg-warning shadow-[0_0_8px_rgba(255,152,0,0.4)]"
        _ -> "bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]"
      end

    assigns = assign(assigns, :status_color, status_color)

    ~H"""
    <div class={["flex items-center gap-2", @class]}>
      <span class={["w-2.5 h-2.5 rounded-full", @status_color]} />
      <span :if={@label} class="text-sm font-interactive text-on-surface-variant">{@label}</span>
    </div>
    """
  end

  @doc """
  Toast notification

  Used for brief success/error messages.
  """
  attr :kind, :string, default: "success"
  attr :title, :string, default: nil
  attr :action_text, :string, default: nil
  attr :action_click, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def toast(assigns) do
    icon =
      case assigns[:kind] do
        "success" -> "check_circle"
        "error" -> "error"
        "info" -> "info"
        "warning" -> "warning"
        _ -> "check_circle"
      end

    icon_color =
      case assigns[:kind] do
        "success" -> "text-green-400"
        "error" -> "text-error"
        "info" -> "text-info"
        "warning" -> "text-warning"
        _ -> "text-green-400"
      end

    assigns = assign(assigns, :icon, icon)
    assigns = assign(assigns, :icon_color, icon_color)

    ~H"""
    <div
      class={[
        "bg-inverse-surface text-inverse-on-surface px-4 py-3 rounded-xl shadow-lg flex items-center justify-between gap-4 max-w-[280px]",
        @class
      ]}
    >
      <div class="flex items-center gap-3">
        <MaterialIcon.icon name={@icon} size="18px" class={@icon_color} />
        <%= if @title do %>
          <span class="text-sm font-semibold">{@title}</span>
        <% end %>
        <span class="text-sm font-body-md">{render_slot(@inner_block)}</span>
      </div>
      <button
        :if={@action_text}
        phx-click={@action_click}
        class="text-inverse-primary hover:text-white transition-colors text-xs font-interactive"
      >
        {@action_text}
      </button>
    </div>
    """
  end
end