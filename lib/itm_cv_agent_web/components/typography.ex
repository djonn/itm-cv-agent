defmodule ItMinds.CvAgentWeb.Typography do
  @moduledoc """
  Typography components based on the design system.

  This module provides consistent text styling across the application
  using the Figtree font family with predefined sizes, weights, and line heights.

  ## Usage

      <Typography.display_large>Intelligence, Refined.</Typography.display_large>
      <Typography.headline_medium>Conversation History</Typography.headline_medium>
      <Typography.body_large>Primary body text content.</Typography.body_large>
      <Typography.interactive>Generate Response</Typography.interactive>
      <Typography.label_caps>System Status: Active</Typography.label_caps>

  """
  use Phoenix.Component

  @doc """
  Display Large typography - 48px, font-weight 800, letter-spacing -0.02em

  Used for main page titles and hero text.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def display_large(assigns) do
    ~H"""
    <p
      class={[
        "font-display text-[48px] leading-[56px] tracking-[-0.02em] font-extrabold text-primary",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Headline Medium typography - 24px, font-weight 700, letter-spacing -0.01em

  Used for section headers and card titles.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def headline_medium(assigns) do
    ~H"""
    <p
      class={[
        "font-headline text-[24px] leading-[32px] tracking-[-0.01em] font-bold text-primary",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Body Large typography - 18px, font-weight 400

  Used for primary body text and paragraphs.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def body_large(assigns) do
    ~H"""
    <p
      class={[
        "font-body text-[18px] leading-[28px] font-normal text-on-surface",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Body Medium typography - 16px, font-weight 400

  Used for secondary text, descriptions, and hints.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def body_medium(assigns) do
    ~H"""
    <p
      class={[
        "font-body text-[16px] leading-[24px] font-normal text-on-surface-variant",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Interactive typography - 14px, font-weight 600

  Used for buttons, links, and interactive elements.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def interactive(assigns) do
    ~H"""
    <p
      class={[
        "font-interactive text-[14px] leading-[20px] font-semibold text-primary",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Label Caps typography - 12px, font-weight 700, letter-spacing 0.05em, uppercase

  Used for labels, badges, and status indicators.
  """
  attr :class, :any, default: nil
  attr :rest, :global, doc: "Additional HTML attributes"
  slot :inner_block, required: true

  def label_caps(assigns) do
    ~H"""
    <p
      class={[
        "font-label text-[12px] leading-[16px] tracking-[0.05em] font-bold uppercase text-secondary",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end
end