defmodule ItMinds.CvAgentWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as tables, forms, and
  inputs. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The foundation for styling is Tailwind CSS with our custom design system.
  We use Material Symbols Outlined for icons via the MaterialIcon component.

  """
  use Phoenix.Component
  alias ItMinds.CvAgentWeb.MaterialIcon
  use Gettext, backend: ItMinds.CvAgentWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash
        id="welcome-back"
        kind={:info}
        phx-mounted={show("#welcome-back") |> JS.remove_attribute("hidden")}
        hidden
      >
        Welcome Back!
      </.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="toast toast-top toast-end z-50"
      {@rest}
    >
      <div class={[
        "alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap rounded-xl shadow-lg px-4 py-3 flex items-start gap-3",
        @kind == :info && "bg-inverse-surface text-inverse-on-surface",
        @kind == :error && "bg-error text-on-error"
      ]}>
        <MaterialIcon.icon :if={@kind == :info} name="info" size="20px" />
        <MaterialIcon.icon :if={@kind == :error} name="error" size="20px" />
        <div>
          <p :if={@title} class="font-semibold">{@title}</p>
          <p>{msg}</p>
        </div>
        <div class="flex-1" />
        <button type="button" class="group self-start cursor-pointer" aria-label={gettext("close")}>
          <MaterialIcon.icon name="close" size="18px" class="opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button with navigation support.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  attr :class, :any
  attr :variant, :string, values: ~w(primary secondary ghost icon text), default: "primary"
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    base_classes = "font-interactive text-interactive transition-colors"

    variant_classes =
      case assigns[:variant] do
        "primary" ->
          "bg-primary-container text-on-primary px-6 py-3 rounded-full hover:bg-primary-container/90 active:scale-[0.98]"

        "secondary" ->
          "bg-transparent border border-outline-variant/50 text-primary px-6 py-3 rounded-full hover:bg-surface-container active:bg-surface-variant"

        "ghost" ->
          "bg-transparent text-secondary px-6 py-3 rounded-full hover:bg-secondary/10 active:bg-secondary/20"

        "icon" ->
          "bg-surface-container-high text-primary p-3 rounded-full hover:bg-surface-variant flex items-center justify-center"

        "text" ->
          "bg-transparent text-primary px-4 py-2 rounded-full hover:text-primary/70 flex items-center gap-2"

        _ ->
          base_classes
      end

    assigns =
      assign_new(assigns, :class, fn ->
        [base_classes, variant_classes]
      end)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={@class} {@rest}>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button class={@class} {@rest}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as radio, are best
  written directly in your templates.

  ## Examples

  ```heex
  <.input field={@form[:email]} type="email" />
  <.input name="my-input" errors={["oh no!"]} />
  ```

  ## Select type

  When using `type="select"`, you must pass the `options` and optionally
  a `value` to mark which option should be preselected.

  ```heex
  <.input field={@form[:user_type]} type="select" options={["Admin": "admin", "User": "user"]} />
  ```

  For more information on what kind of data can be passed to `options` see
  [`options_for_select`](https://phoenix-html.hexdocs.pm/Phoenix.HTML.Form.html#options_for_select/2).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="flex items-center gap-3">
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        class="w-5 h-5 rounded border-outline text-primary-container focus:ring-primary-container bg-surface-container-low cursor-pointer"
        {@rest}
      />
      <label :if={@label} for={@id} class="font-body-md text-on-surface cursor-pointer">
        {@label}
      </label>
    </div>
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@id} class="text-sm font-interactive text-on-surface-variant">
        {@label}
      </label>
      <div class="relative">
        <select
          id={@id}
          name={@name}
          class={[
            "w-full bg-surface-container-low border border-outline-variant/30 rounded-2xl py-3 pl-4 pr-12 text-primary appearance-none focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container transition-all font-body-md cursor-pointer",
            @class,
            @errors != [] && (@error_class || "border-error")
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
        <MaterialIcon.icon
          name="expand_more"
          size="20px"
          class="absolute right-4 top-1/2 -translate-y-1/2 text-on-surface-variant pointer-events-none"
        />
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@id} class="text-sm font-interactive text-on-surface-variant">
        {@label}
      </label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "w-full bg-surface-container-low border border-outline-variant/30 rounded-2xl py-3 px-4 text-primary placeholder-on-surface-variant/50 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container transition-all font-body-md resize-none",
          @class,
          @errors != [] && (@error_class || "border-error")
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@id} class="text-sm font-interactive text-on-surface-variant">
        {@label}
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "w-full bg-surface-container-low border border-outline-variant/30 rounded-2xl py-3 px-4 text-primary placeholder-on-surface-variant/50 focus:outline-none focus:border-primary-container focus:ring-1 focus:ring-primary-container transition-all font-body-md",
          @class,
          @errors != [] && (@error_class || "border-error")
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # Helper used by inputs to generate form errors
  defp error(assigns) do
    ~H"""
    <p class="mt-1.5 flex gap-2 items-center text-sm text-error">
      <MaterialIcon.icon name="error" size="16px" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.

  ## Examples

      <.header>
        Page Title
        <:subtitle>Optional subtitle</:subtitle>
      </.header>
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4 border-b border-outline-variant/20"]}>
      <div>
        <h1 class="text-xl font-semibold leading-8 text-primary">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-base text-on-surface-variant mt-1">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-hidden rounded-2xl border border-outline-variant/10">
      <table class="w-full">
        <thead class="bg-surface-container-high">
          <tr>
            <th
              :for={col <- @col}
              class="px-6 py-3 text-left text-xs font-interactive text-on-surface-variant uppercase tracking-wide"
            >
              {col[:label]}
            </th>
            <th :if={@action != []} class="px-6 py-3">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
          class="divide-y divide-outline-variant/10 bg-surface"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="hover:bg-surface-container/50">
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={[@row_click && "cursor-pointer", "px-6 py-4 text-sm text-on-surface"]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="px-6 py-4">
              <div class="flex gap-4">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <ul class="divide-y divide-outline-variant/10">
      <li :for={item <- @item} class="py-4">
        <div class="font-semibold text-primary">{item.title}</div>
        <div class="text-on-surface-variant">{render_slot(item)}</div>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(ItMinds.CvAgentWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ItMinds.CvAgentWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end