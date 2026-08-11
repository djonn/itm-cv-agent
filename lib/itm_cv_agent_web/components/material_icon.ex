defmodule ItMinds.CvAgentWeb.MaterialIcon do
  @moduledoc """
  Provides Material Symbols Outlined icon components.

  Material Symbols are Google's icon library with variable font weight and fill options.
  This wrapper provides a consistent interface for using icons throughout the application.

  ## Usage

      <ItMinds.CvAgentWeb.MaterialIcon.name="chat" />
      <ItMinds.CvAgentWeb.MaterialIcon.name="settings" class="text-primary" />
      <ItMinds.CvAgentWeb.MaterialIcon.name="auto_awesome" filled />
      <ItMinds.CvAgentWeb.MaterialIcon.name="search" size="20px" />

  ## Icon Names

  Use the Material Symbols Outlined icon names. Some common ones:
  - chat, settings, search, add, close, check, menu
  - auto_awesome, smart_toy, insert_drive_file (AI-related)
  - thumb_up, thumb_down, refresh, content_copy (actions)
  - mic, attach_file, image, arrow_upward (input)
  - folder, home, info, check_circle (navigation/status)

  ## Attributes

    * `:name` - The icon name (required)
    * `:class` - Additional CSS classes
    * `:size` - Icon size in pixels (default: "24px")
    * `:filled` - Whether the icon should be filled (default: false)
    * `:weight` - Font weight 100-700 (default: 400)
    * `:grade` - Font grade -25 to 200 (default: 0)
    * `:rest` - Any other HTML attributes

  """
  use Phoenix.Component

  attr :name, :string, required: true, doc: "The Material Symbol icon name"
  attr :class, :any, default: "", doc: "Additional CSS classes"
  attr :size, :string, default: "24px", doc: "Icon size"
  attr :filled, :boolean, default: false, doc: "Whether to fill the icon"
  attr :weight, :string, default: "400", doc: "Font weight (100-700)"
  attr :grade, :string, default: "0", doc: "Font grade (-25 to 200)"
  attr :rest, :global, doc: "Additional HTML attributes"

  def icon(assigns) do
    ~H"""
    <span
      class={["material-symbols-outlined", @class]}
      style={["font-size: #{@size}", "font-variation-settings: 'FILL' #{if @filled, do: 1, else: 0}, 'wght' #{@weight}, 'GRAD' #{@grade}, 'opsz' 24"]}
      {@rest}
    >
      {@name}
    </span>
    """
  end
end