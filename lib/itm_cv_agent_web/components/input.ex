defmodule ItMinds.CvAgentWeb.Input do
  @moduledoc """
  Input components based on the design system.

  This module provides specialized input components beyond the core input/1
  from CoreComponents, including search, toggle, and prompt inputs.

  ## Usage

      <Input.search value={@search} phx-change="search" />
      <Input.toggle checked={@enabled} phx-click="toggle" />
      <Input.prompt field={@form[:message]} />

  """
  use Phoenix.Component
  alias ItMinds.CvAgentWeb.MaterialIcon

  @doc """
  Search input with leading icon

  Used for search fields with a magnifying glass icon.
  """
  attr :id, :string, default: "search-input"
  attr :name, :string, default: "search"
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Search..."
  attr :class, :any, default: nil
  attr :rest, :global

  def search(assigns) do
    ~H"""
    <div class="relative">
      <MaterialIcon.icon
        name="search"
        size="20px"
        class="absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant/70"
      />
      <input
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        class={[
          "w-full bg-surface-container-low border border-outline-variant/30 rounded-2xl py-3 pl-12 pr-4",
          "text-primary placeholder-on-surface-variant/50",
          "focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container transition-all",
          @class
        ]}
        {@rest}
      />
    </div>
    """
  end

  @doc """
  Toggle switch component

  Used for on/off settings like "Web Search" or "Save to history".
  """
  attr :id, :string, default: "toggle"
  attr :name, :string, default: "toggle"
  attr :checked, :boolean, default: false
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def toggle(assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <div class="relative inline-block w-12 align-middle select-none transition duration-200 ease-in">
        <input
          type="checkbox"
          id={@id}
          name={@name}
          checked={@checked}
          class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 border-surface-container-highest appearance-none cursor-pointer transition-all duration-300 z-10 top-0 left-0"
          {@rest}
        />
        <label
          for={@id}
          class="toggle-label block overflow-hidden h-6 rounded-full bg-surface-container-highest cursor-pointer transition-all duration-300"
        />
      </div>
      <span :if={@label} class="font-body-md text-on-surface">{@label}</span>
    </div>
    """
  end

  @doc """
  Prompt input - multi-line textarea with attachment buttons

  Used for AI chat input with file attachment and image upload options.
  """
  attr :id, :string, default: "prompt-input"
  attr :name, :string, default: "prompt"
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Message..."
  attr :show_attachments, :boolean, default: true
  attr :show_image, :boolean, default: true
  attr :show_send, :boolean, default: true
  attr :class, :any, default: nil
  attr :rest, :global

  attr :on_attach, :string, default: nil, doc: "phx-click event for attachment button"
  attr :on_image, :string, default: nil, doc: "phx-click event for image button"
  attr :on_send, :string, default: nil, doc: "phx-click event for send button"

  def prompt(assigns) do
    ~H"""
    <div class={[
      "bg-surface-container-low border border-outline-variant/30 rounded-[24px] p-2 flex flex-col shadow-inner focus-within:border-primary-container focus-within:ring-1 focus-within:ring-primary-container transition-all",
      @class
    ]}>
      <textarea
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        class="w-full bg-transparent border-none resize-none py-3 px-4 text-primary placeholder-on-surface-variant/50 focus:ring-0 min-h-[100px] font-body-md"
        {@rest}
      />
      <div :if={@show_attachments || @show_image || @show_send} class="flex justify-between items-center px-2 pb-2">
        <div :if={@show_attachments || @show_image} class="flex gap-2">
          <button
            :if={@show_attachments}
            type="button"
            phx-click={@on_attach}
            class="text-on-surface-variant hover:text-primary hover:bg-surface-variant p-2 rounded-full transition-colors flex items-center justify-center"
          >
            <MaterialIcon.icon name="attach_file" size="20px" />
          </button>
          <button
            :if={@show_image}
            type="button"
            phx-click={@on_image}
            class="text-on-surface-variant hover:text-primary hover:bg-surface-variant p-2 rounded-full transition-colors flex items-center justify-center"
          >
            <MaterialIcon.icon name="image" size="20px" />
          </button>
        </div>
        <button
          :if={@show_send}
          type="button"
          phx-click={@on_send}
          class="bg-primary-container text-on-primary p-2 rounded-full hover:bg-primary-container/90 transition-colors flex items-center justify-center shadow-sm"
        >
          <MaterialIcon.icon name="arrow_upward" size="20px" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Dropdown select with custom styling

  Used for model selection or other dropdown menus.
  """
  attr :id, :string, default: "select-input"
  attr :name, :string, default: "select"
  attr :value, :string, default: nil
  attr :options, :list, required: true
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def dropdown(assigns) do
    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@id} class="text-sm font-interactive text-on-surface-variant">
        {@label}
      </label>
      <div class="relative">
        <select
          id={@id}
          name={@name}
          value={@value}
          class={[
            "w-full bg-surface-container-low border border-outline-variant/30 rounded-2xl py-3 pl-4 pr-12 text-primary appearance-none",
            "focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container transition-all",
            "font-body-md cursor-pointer",
            @class
          ]}
          {@rest}
        >
          <%= for option <- @options do %>
            <%= if is_tuple(option) do %>
              <option value={elem(option, 1)}><%= elem(option, 0) %></option>
            <% else %>
              <option value={option}><%= option %></option>
            <% end %>
          <% end %>
        </select>
        <MaterialIcon.icon
          name="expand_more"
          size="20px"
          class="absolute right-4 top-1/2 -translate-y-1/2 text-on-surface-variant pointer-events-none"
        />
      </div>
    </div>
    """
  end
end