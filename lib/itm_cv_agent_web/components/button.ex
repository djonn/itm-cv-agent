defmodule ItMinds.CvAgentWeb.Button do
  @moduledoc """
  Button components based on the design system.

  This module provides consistent button styling across the application
  with multiple variants for different use cases.

  ## Usage

      <Button.primary>Generate Response</Button.primary>
      <Button.secondary>Cancel</Button.secondary>
      <Button.ghost>Delete</Button.ghost>
      <Button.icon_button><MaterialIcon.icon name="mic" /></Button.icon_button>
      <Button.text><MaterialIcon.icon name="add" /> New Chat</Button.text>

  """
  use Phoenix.Component

  @doc """
  Primary button - filled with primary-container background

  Used for primary actions like submit, save, or main CTAs.

  ## States
    * Default - Full opacity
    * Hover - 90% opacity
    * Active - 80% opacity with scale transform
    * Disabled - 50% opacity with not-allowed cursor
  """
  attr :class, :any, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(phx-click phx-submit navigate patch href)
  slot :inner_block, required: true

  def primary(assigns) do
    ~H"""
    <button
      class={[
        "bg-primary-container text-on-primary font-interactive text-interactive px-6 py-3 rounded-full transition-colors w-full text-center",
        "hover:bg-primary-container/90 active:scale-[0.98]",
        @disabled && "bg-surface-container text-on-surface-variant/50 cursor-not-allowed hover:bg-surface-container active:scale-100",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Secondary button - outlined with border

  Used for secondary actions like cancel, back, or alternative actions.

  ## States
    * Default - Transparent background with border
    * Hover - Surface container background
    * Active - Surface variant background
    * Disabled - Low opacity border and text
  """
  attr :class, :any, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(phx-click phx-submit navigate patch href)
  slot :inner_block, required: true

  def secondary(assigns) do
    ~H"""
    <button
      class={[
        "bg-transparent border border-outline-variant/50 text-primary font-interactive text-interactive px-6 py-3 rounded-full transition-colors w-full text-center",
        "hover:bg-surface-container active:bg-surface-variant active:border-outline-variant/60",
        @disabled && "bg-transparent border-outline-variant/20 text-on-surface-variant/50 cursor-not-allowed hover:bg-transparent active:bg-transparent",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Ghost button - text-only with hover background

  Used for tertiary actions, filters, or less prominent actions.

  ## States
    * Default - Transparent background
    * Hover - 10% secondary color background
    * Active - 20% secondary color background
    * Disabled - 30% opacity
  """
  attr :class, :any, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(phx-click phx-submit navigate patch href)
  slot :inner_block, required: true

  def ghost(assigns) do
    ~H"""
    <button
      class={[
        "bg-transparent text-secondary font-interactive text-interactive px-6 py-3 rounded-full transition-colors w-full text-center",
        "hover:bg-secondary/10 active:bg-secondary/20 active:scale-[0.98]",
        @disabled && "bg-transparent text-secondary/30 cursor-not-allowed hover:bg-transparent active:bg-transparent active:scale-100",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Icon button - circular button for icon-only actions

  Used for compact actions like mic, attach, send, etc.

  ## States
    * Default - Surface container high background
    * Hover - Surface variant background
    * Active - Scaled down with surface variant background
    * Disabled - Low opacity
  """
  attr :class, :any, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(phx-click phx-submit)
  slot :inner_block, required: true

  def icon_button(assigns) do
    ~H"""
    <button
      class={[
        "bg-surface-container-high text-primary p-3 rounded-full transition-colors flex items-center justify-center",
        "hover:bg-surface-variant active:scale-[0.95] active:bg-surface-variant/80",
        @disabled && "bg-surface-container text-on-surface-variant/30 cursor-not-allowed hover:bg-surface-container active:scale-100",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Text button - simple text button with optional icon

  Used for navigation items, list actions, or minimal UI contexts.

  ## States
    * Default - Full opacity text
    * Hover - 70% opacity
    * Active - 50% opacity
  """
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(phx-click phx-submit navigate patch href)
  slot :inner_block, required: true

  def text(assigns) do
    ~H"""
    <.link
      class={[
        "text-primary font-interactive text-interactive transition-colors w-full text-left flex items-center gap-2",
        "hover:text-primary/70 active:text-primary/50",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end