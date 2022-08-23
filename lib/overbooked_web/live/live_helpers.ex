defmodule OverbookedWeb.LiveHelpers do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  ## String formatters

  def relative_time(nil), do: ""

  def relative_time(datetime) do
    {:ok, str} = Timex.format(datetime, "{relative}", :relative)
    str
  end

  def from_to_datetime(from_date, to_date) do
    same_year = Timex.compare(from_date, to_date, :year) == 0
    same_month = Timex.compare(from_date, to_date, :month) == 0
    same_day = Timex.compare(from_date, to_date, :day) == 0

    {:ok, from_date_str} =
      Timex.format(from_date, "#{if !same_year, do: "{YYYY}"} {Mshort} {D} {h24}:{m}")

    {:ok, to_date_str} =
      Timex.format(
        to_date,
        "#{if !same_year, do: "{YYYY}"} #{if !same_month, do: "{Mshort}"} #{if same_day, do: "{h24}:{m}", else: "{D} {h24}:{m}"}"
      )

    "#{from_date_str} - #{to_date_str}"
  end

  def from_to_datetime(from_date, to_date, :hours) do
    {:ok, from_date_str} = Timex.format(from_date, "{h24}:{m}")
    {:ok, to_date_str} = Timex.format(to_date, "{h24}:{m}")

    "#{from_date_str} - #{to_date_str}"
  end

  attr :flash, :map
  attr :kind, :atom

  def flash(%{kind: :error} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-red-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={
          JS.push("lv:clear-flash")
          |> JS.remove_class("fade-in-scale", to: "#flash")
          |> hide("#flash")
        }
        phx-hook="Flash"
      >
        <div class="flex justify-between items-center space-x-3 text-red-700">
          <.icon name={:exclamation_circle} class="w-5 w-5" />
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button
            type="button"
            class="inline-flex bg-red-50 rounded-md p-1.5 text-red-500 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-600"
          >
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def flash(%{kind: :info} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-green-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={JS.push("lv:clear-flash") |> JS.remove_class("fade-in-scale") |> hide("#flash")}
        phx-value-key="info"
        phx-hook="Flash"
      >
        <div class="flex justify-between items-center space-x-3 text-green-700">
          <.icon name={:check_circle} class="w-5 h-5" />
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button
            type="button"
            class="inline-flex bg-green-50 rounded-md p-1.5 text-green-500 hover:bg-green-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600"
          >
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def spinner(assigns) do
    ~H"""
    <svg
      class="inline-block animate-spin h-2.5 w-2.5 text-gray-400"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
      </circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      >
      </path>
    </svg>
    """
  end

  attr :name, :atom, required: true
  attr :outlined, :boolean, default: false
  attr :rest, :global, default: %{class: "w-4 h-4 inline-block"}

  def icon(assigns) do
    assigns = assign_new(assigns, :"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <%= if @outlined do %>
      <%= apply(Heroicons.Outline, @name, [Map.to_list(@rest)]) %>
    <% else %>
      <%= apply(Heroicons.Solid, @name, [Map.to_list(@rest)]) %>
    <% end %>
    """
  end

  @doc """
  Returns a button triggered dropdown with aria keyboard and focus supporrt.
  Accepts the follow slots:
    * `:id` - The id to uniquely identify this dropdown
    * `:img` - The optional img to show beside the button title
    * `:title` - The button title
    * `:subtitle` - The button subtitle
  ## Examples
      <.dropdown id={@id}>
        <:img src={@current_user.avatar_url}/>
        <:title><%= @current_user.name %></:title>
        <:subtitle>@<%= @current_user.username %></:subtitle>
        <:link navigate={profile_path(@current_user)}>View Profile</:link>
        <:link navigate={Routes.settings_path(OverbookedWeb.Endpoint, :edit)}Settings</:link>
      </.dropdown>
  """
  attr :id, :string, required: true
  attr :ok, :string, required: true
  attr :img, :list, default: []
  attr :title, :list, default: []
  attr :subtitle, :list, default: []
  attr :link, :list, default: []

  def dropdown(assigns) do
    ~H"""
    <div class="px-3 relative inline-block text-left">
      <div>
        <button
          id={@id}
          type="button"
          class="border rounded-md border-2 group w-full bg-gray-100 rounded-md px-3.5 py-2 text-sm text-left font-medium text-gray-700 hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-purple-500"
          phx-click={show_dropdown("##{@id}-dropdown")}
          data-active-class="bg-gray-100"
          aria-haspopup="true"
        >
          <span class="flex w-full justify-between items-center">
            <span class="flex min-w-0 items-center justify-between space-x-3">
              <%= for img <- @img do %>
                <img
                  class="w-10 h-10 bg-gray-300 rounded-full flex-shrink-0"
                  alt=""
                  {assigns_to_attributes(img)}
                />
              <% end %>
              <span class="flex-1 flex flex-col min-w-0">
                <span class="text-gray-900 text-sm font-medium truncate">
                  <%= render_slot(@title) %>
                </span>
                <span class="text-gray-500 text-sm truncate"><%= render_slot(@subtitle) %></span>
              </span>
            </span>
            <svg
              class="flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-500"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M10 3a1 1 0 01.707.293l3 3a1 1 0 01-1.414 1.414L10 5.414 7.707 7.707a1 1 0 01-1.414-1.414l3-3A1 1 0 0110 3zm-3.707 9.293a1 1 0 011.414 0L10 14.586l2.293-2.293a1 1 0 011.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
          </span>
        </button>
      </div>
      <div
        id={"#{@id}-dropdown"}
        phx-click-away={hide_dropdown("##{@id}-dropdown")}
        class="hidden z-10 mx-3 origin-top absolute right-0 left-0 mt-1 min-w-max rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 divide-y divide-gray-200"
        role="menu"
        aria-labelledby={@id}
      >
        <div class="py-1" role="none">
          <%= for link <- @link do %>
            <.link
              tabindex="-1"
              role="menuitem"
              class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-purple-500"
              {link}
            >
              <%= render_slot(link) %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      display: "inline-block",
      transition:
        {"ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition ease-in duration-300", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end

  def show_dropdown(to) do
    JS.show(
      to: to,
      transition:
        {"transition ease-out duration-120", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  def hide_dropdown(to) do
    JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-120", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(
      to: "##{id}",
      display: "inline-block",
      transition: {"ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "##{id}-container",
      display: "inline-block",
      transition:
        {"ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
    |> js_exec("##{id}-confirm", "focus", [])
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_class("fade-in", to: "##{id}")
    |> JS.hide(
      to: "##{id}",
      transition: {"ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.hide(
      to: "##{id}-container",
      transition:
        {"ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
    |> JS.dispatch("click", to: "##{id} [data-modal-return]")
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :icon, :atom, default: :information_circle
  attr :patch, :string, default: nil
  attr :navigate, :string, default: nil
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}
  # slots
  attr :title, :list, default: []
  attr :confirm, :list, default: []
  attr :cancel, :list, default: []
  attr :rest, :global

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={"fixed z-10 inset-0 overflow-y-auto #{if @show, do: "fade-in", else: "hidden"}"}
      {@rest}
    >
      <.focus_wrap id={"#{@id}-focus-wrap"} content={"##{@id}-container"}>
        <div
          class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0"
          aria-labelledby={"#{@id}-title"}
          aria-describedby={"#{@id}-description"}
          role="dialog"
          aria-modal="true"
          tabindex="0"
        >
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true">
          </div>
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
            &#8203;
          </span>
          <div
            id={"#{@id}-container"}
            class={
              "#{if @show, do: "fade-in-scale", else: "hidden"} sticky inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform sm:my-8 sm:align-middle sm:max-w-xl sm:w-full sm:p-6"
            }
            phx-key="escape"
          >
            <%= if @patch do %>
              <.link patch={@patch} data-modal-return class="hidden"></.link>
            <% end %>
            <%= if @navigate do %>
              <.link navigate={@navigate} data-modal-return class="hidden"></.link>
            <% end %>
            <div class="sm:flex sm:items-start">
              <%= if @icon do %>
                <div class="mx-auto flex-shrink-0 flex items-center justify-center h-8 w-8 rounded-full bg-purple-100 sm:mx-0">
                  <!-- Heroicon name: outline/plus -->
                  <.icon name={@icon || :information_circle} outlined class="h-6 w-6 text-purple-600" />
                </div>
              <% end %>

              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full mr-4">
                <h3 class="text-lg leading-6 font-medium text-gray-900" id={"#{@id}-title"}>
                  <%= render_slot(@title) %>
                </h3>
                <div class="mt-6">
                  <p id={"#{@id}-content"} class="text-sm text-gray-500">
                    <%= render_slot(@inner_block) %>
                  </p>
                </div>
              </div>
            </div>
            <div class="sm:ml-4 mr-4 mt-8 flex flex-row flex-row-reverse space-x-2 space-x-reverse">
              <%= for confirm <- @confirm do %>
                <.button
                  id={"#{@id}-confirm"}
                  phx-click={@on_confirm}
                  phx-disable-with
                  {assigns_to_attributes(confirm)}
                >
                  <%= render_slot(confirm) %>
                </.button>
              <% end %>
              <%= for cancel <- @cancel do %>
                <.button phx-click={hide_modal(@on_cancel, @id)} {assigns_to_attributes(cancel)}>
                  <%= render_slot(cancel) %>
                </.button>
              <% end %>
            </div>
          </div>
        </div>
      </.focus_wrap>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :value, :integer

  def progress_bar(assigns) do
    assigns = assign_new(assigns, :value, fn -> assigns[:min] || 0 end)

    ~H"""
    <div
      id={"#{@id}-container"}
      class="bg-gray-200 flex-auto dark:bg-black rounded-full overflow-hidden"
      phx-update="ignore"
    >
      <div
        id={@id}
        class="bg-lime-500 dark:bg-lime-400 h-1.5 w-0"
        data-min={@min}
        data-max={@max}
        data-val={@value}
      >
      </div>
    </div>
    """
  end

  attr :actions, :list, default: []

  def title_bar(assigns) do
    ~H"""
    <!-- Page title & actions -->
    <div class="border-b border-gray-200 px-4 py-4 sm:flex sm:items-center sm:justify-between sm:px-6 lg:px-8 sm:h-16">
      <div class="flex-1 min-w-0">
        <h1 class="text-lg font-medium leading-6 text-gray-900 sm:truncate focus:outline-none">
          <%= render_slot(@inner_block) %>
        </h1>
      </div>
      <%= if Enum.count(@actions) > 0 do %>
        <div class="mt-4 flex sm:mt-0 sm:ml-4 space-x-4">
          <%= render_slot(@actions) %>
        </div>
      <% end %>
    </div>
    """
  end

  def badge(%{color: color} = assigns) do
    ~H"""
    <span class={"inline-flex items-center bg-#{color}-100 text-#{color}-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded dark:bg-#{color}-200 dark:text-#{color}-800"}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr :patch, :string
  attr :size, :atom, default: :base
  attr :type, :string, default: "button"
  attr :variant, :atom, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global

  def button(%{patch: _} = assigns) do
    ~H"""
    <%= if @primary do %>
      <%= live_patch [to: @patch, class: "order-0 inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 sm:order-1"] ++
        Map.to_list(@rest) do %>
        <%= render_slot(@inner_block) %>
      <% end %>
    <% else %>
      <%= live_patch [to: @patch, class: "order-1 inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 sm:order-0"] ++
        assigns_to_attributes(assigns, [:primary, :patch]) do %>
        <%= render_slot(@inner_block) %>
      <% end %>
    <% end %>
    """
  end

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={"#{button_classes_base()} #{button_classes_color(@variant)} #{button_classes_size(@size)} #{if @disabled, do: "opacity-50 cursor-default hover:bg-inherit"}"}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp button_classes_size(size) do
    case size do
      :base -> "text-sm px-4 py-2"
      :small -> "text-xs px-2 py-1"
      _ -> "text-sm px-4 py-2"
    end
  end

  defp button_classes_color(variant) do
    case variant do
      :primary -> "border-primary-300 text-primary-700 bg-white hover:bg-primary-50"
      :secondary -> "border-secondary-400 text-secondary-700 bg-white hover:bg-secondary-50"
      :danger -> "border-danger-300 text-danger-700 bg-white hover:bg-danger-50"
      _ -> "border-primary-300 text-primary-700 bg-white hover:bg-primary-50"
    end
  end

  defp button_classes_base() do
    "font-medium inline-flex items-center border shadow-sm rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
  end

  attr :row_id, :any, default: false
  attr :rows, :list, required: true
  # slots
  attr :col, :list, required: true

  def table(assigns) do
    assigns =
      assigns
      |> assign_new(:row_id, fn -> false end)
      |> assign(:col, for(col <- assigns.col, col[:if] != false, do: col))

    ~H"""
    <div class="hidden mt-8 sm:block">
      <div class="align-middle inline-block min-w-full border-b border-gray-200">
        <table class="w-full table-fixed">
          <thead>
            <tr class="border-t border-gray-200">
              <%= for col <- @col do %>
                <th class={"#{if Map.has_key?(col, :width), do: col.width} px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"}>
                  <span class="lg:pl-2"><%= col.label %></span>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            <%= for {row, _i} <- Enum.with_index(@rows) do %>
              <tr id={@row_id && @row_id.(row)} class="hover:bg-gray-50">
                <%= for col <- @col do %>
                  <td class={
                    "px-6 py-3 text-sm font-medium text-gray-900 #{col[:class]}"
                  }>
                    <div class="flex items-center space-x-3 lg:pl-2">
                      <%= render_slot(col, row) %>
                    </div>
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  attr :id, :any, required: true
  attr :module, :atom, required: true
  attr :row_id, :any, default: false
  attr :rows, :list, required: true
  attr :owns_profile?, :boolean, default: false
  attr :active_id, :any, default: nil
  # slots
  attr :col, :list

  def live_table(assigns) do
    assigns = assign(assigns, :col, for(col <- assigns.col, col[:if] != false, do: col))

    ~H"""
    <div class="hidden mt-8 sm:block">
      <div class="align-middle inline-block min-w-full border-b border-gray-200">
        <table class="min-w-full">
          <thead>
            <tr class="border-t border-gray-200">
              <%= for col <- @col do %>
                <th class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <span class="lg:pl-2"><%= col.label %></span>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody id={@id} class="bg-white divide-y divide-gray-100" phx-update="append">
            <%= for {row, i} <- Enum.with_index(@rows) do %>
              <.live_component
                module={@module}
                id={@row_id.(row)}
                row={row}
                col={@col}
                index={i}
                active_id={@active_id}
                class="hover:bg-gray-50"
                ,
                owns_profile?={@owns_profile?}
              />
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  attr :label, :string

  def header(assigns) do
    ~H"""
    <div class="border-b border-gray-200 px-4 py-4 sm:flex sm:items-center sm:justify-between sm:px-6 lg:px-8 sm:h-16">
      <div class="min-w-0 mr-6">
        <h1 tabindex="-1">
          <%= @label %>
        </h1>
      </div>
      <div class="flex-1">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :full, :boolean, default: false

  def page(assigns) do
    ~H"""
    <div class={"px-4 py-4 sm:px-6 lg:px-8 w-full #{if !@full, do: "mx-auto max-w-4xl"}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Calls a wired up event listener to call a function with arguments.
      window.addEventListener("js:exec", e => e.target[e.detail.call](...e.detail.args))
  """
  def js_exec(js \\ %JS{}, to, call, args) do
    JS.dispatch(js, "js:exec", to: to, detail: %{call: call, args: args})
  end

  def focus(js \\ %JS{}, parent, to) do
    JS.dispatch(js, "js:focus", to: to, detail: %{parent: parent})
  end

  def focus_closest(js \\ %JS{}, to) do
    js
    |> JS.dispatch("js:focus-closest", to: to)
    |> hide(to)
  end
end
