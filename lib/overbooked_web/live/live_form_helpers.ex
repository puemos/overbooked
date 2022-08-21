defmodule OverbookedWeb.LiveFormHelpers do
  use Phoenix.Component

  import Phoenix.HTML.Form

  ## Forms
  def text_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= text_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def email_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= email_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def number_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= number_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def password_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= password_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def switch(assigns) do
    assigns = assign_defaults(assigns, switch_classes(field_has_errors?(assigns)))

    ~H"""
    <label class="relative inline-flex items-center justify-center flex-shrink-0 w-10 h-5 group">
      <%= checkbox(
        @form,
        @field,
        [
          class: @classes,
          phx_feedback_for: input_name(@form, @field)
        ] ++ @rest
      ) %>
      <span class="absolute h-6 mx-auto transition-colors duration-200 ease-in-out bg-gray-200 border rounded-full pointer-events-none w-11 dark:bg-gray-700 dark:border-gray-600 peer-checked:bg-primary-500">
      </span>
      <span class="absolute left-0 inline-block w-5 h-5 transition-transform duration-200 ease-in-out transform translate-x-0 bg-white rounded-full shadow pointer-events-none peer-checked:translate-x-5 ring-0 ">
      </span>
    </label>
    """
  end

  def radio(assigns) do
    assigns = assign_defaults(assigns, radio_classes(field_has_errors?(assigns)))

    ~H"""
    <%= radio_button(
      @form,
      @field,
      @value,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def textarea(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= textarea(
      @form,
      @field,
      [class: @classes, rows: "4", phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def select(assigns) do
    assigns = assign_defaults(assigns, select_classes(field_has_errors?(assigns)))

    ~H"""
    <%= select(
      @form,
      @field,
      @options,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def checkbox(assigns) do
    assigns = assign_defaults(assigns, checkbox_classes(field_has_errors?(assigns)))

    ~H"""
    <%= checkbox(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def checkbox_group(assigns) do
    assigns =
      assigns
      |> assign_defaults(checkbox_classes(field_has_errors?(assigns)))
      |> assign_new(:checked, fn ->
        values =
          case input_value(assigns[:form], assigns[:field]) do
            value when is_binary(value) -> [value]
            value when is_list(value) -> value
            _ -> []
          end

        Enum.map(values, &to_string/1)
      end)
      |> assign_new(:id_prefix, fn -> input_id(assigns[:form], assigns[:field]) <> "_" end)
      |> assign_new(:layout, fn -> :col end)

    ~H"""
    <div class={checkbox_group_layout_classes(%{layout: @layout})}>
      <%= hidden_input(@form, @field, name: input_name(@form, @field), value: "") %>
      <%= for {label, value} <- @options do %>
        <label class={checkbox_group_layout_item_classes(%{layout: @layout})}>
          <.checkbox
            form={@form}
            field={@field}
            id={@id_prefix <> to_string(value)}
            name={input_name(@form, @field) <> "[]"}
            checked_value={value}
            unchecked_value=""
            value={value}
            checked={to_string(value) in @checked}
            hidden_input={false}
            {@rest}
          />
          <div class={label_classes(%{form: @form, field: @field, type: "checkbox"})}>
            <%= label %>
          </div>
        </label>
      <% end %>
    </div>
    """
  end

  def telephone_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= telephone_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def url_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= url_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def time_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= time_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def time_select(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <div class="select-wrapper dark:text-white">
      <%= time_select(
        @form,
        @field,
        [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
      ) %>
    </div>
    """
  end

  def datetime_local_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= datetime_local_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def datetime_select(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <div class="select-wrapper dark:text-white">
      <%= datetime_select(
        @form,
        @field,
        [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
      ) %>
    </div>
    """
  end

  def date_select(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <div class="select-wrapper dark:text-white">
      <%= date_select(
        @form,
        @field,
        [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
      ) %>
    </div>
    """
  end

  def date_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= date_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def search_input(assigns) do
    assigns = assign_defaults(assigns, text_input_classes(field_has_errors?(assigns)))

    ~H"""
    <%= search_input(
      @form,
      @field,
      [class: @classes, phx_feedback_for: input_name(@form, @field)] ++ @rest
    ) %>
    """
  end

  def error(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <div class={@class}>
      <%= for error <- Keyword.get_values(@form.errors, @field) do %>
        <div
          class="text-xs italic text-red-500 invalid-feedback"
          phx-feedback-for={input_name(@form, @field)}
        >
          <%= translate_error(error) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp translate_error({msg, opts}) do
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      try do
        String.replace(acc, "%{#{key}}", to_string(value))
      rescue
        e ->
          IO.warn(
            """
            the fallback message translator for the form_field_error function cannot handle the given value.
            Hint: you can set up the `error_translator_function` to route all errors to your application helpers:
              config :petal_components, :error_translator_function, {MyAppWeb.ErrorHelpers, :translate_error}
            Given value: #{inspect(value)}
            Exception: #{Exception.message(e)}
            """,
            __STACKTRACE__
          )

          "invalid value"
      end
    end)
  end

  defp assign_defaults(assigns, base_classes) do
    assigns
    |> assign_new(:type, fn -> "text" end)
    |> assign_rest(~w(class label form field type options layout)a)
    |> assign_new(:classes, fn ->
      build_class([
        base_classes,
        assigns[:class]
      ])
    end)
  end

  def build_class(list, joiner \\ " ")
  def build_class([], _joiner), do: ""

  def build_class(list, joiner) when is_list(list) do
    join_non_empty_list(list, joiner, [])
    |> :lists.reverse()
    |> IO.iodata_to_binary()
  end

  def assign_rest(assigns, exclude) do
    Phoenix.LiveView.assign(
      assigns,
      :rest,
      Phoenix.LiveView.Helpers.assigns_to_attributes(assigns, exclude)
    )
  end

  # Remove joiner (if present), since our last element was empty and isn't added
  defp join_non_empty_list([""], joiner, [joiner | acc]), do: acc
  defp join_non_empty_list([nil], joiner, [joiner | acc]), do: acc
  defp join_non_empty_list([""], _joiner, acc), do: acc
  defp join_non_empty_list([nil], _joiner, acc), do: acc
  defp join_non_empty_list([first], _joiner, acc), do: [entry_to_string(first) | acc]

  # Don't append empty string to our class list
  defp join_non_empty_list(["" | rest], joiner, acc) do
    join_non_empty_list(rest, joiner, acc)
  end

  defp join_non_empty_list([nil | rest], joiner, acc) do
    join_non_empty_list(rest, joiner, acc)
  end

  defp join_non_empty_list([first | rest], joiner, acc) do
    join_non_empty_list(rest, joiner, [joiner, entry_to_string(first) | acc])
  end

  # Trim the input string
  defp entry_to_string(entry) when is_binary(entry), do: String.trim(entry)
  defp entry_to_string(entry), do: String.trim(String.Chars.to_string(entry))

  defp text_input_classes(has_error) do
    "#{if has_error, do: "has-error", else: ""} border-gray-300 focus:border-primary-500 focus:ring-primary-500 dark:border-gray-600 dark:focus:border-primary-500 sm:text-sm block disabled:bg-gray-100 disabled:cursor-not-allowed shadow-sm w-full rounded-md dark:bg-gray-800 dark:text-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
  end

  defp select_classes(has_error) do
    "#{if has_error, do: "has-error", else: ""} border-gray-300 focus:border-primary-500 focus:ring-primary-500 dark:border-gray-600 dark:focus:border-primary-500 block w-full disabled:bg-gray-100 disabled:cursor-not-allowed pl-3 pr-10 py-2 text-base focus:outline-none sm:text-sm rounded-md dark:border-gray-600 dark:focus:border-primary-500 dark:text-gray-300 dark:bg-gray-800"
  end

  defp checkbox_classes(has_error) do
    "#{if has_error, do: "has-error", else: ""} border-gray-300 text-primary-700 rounded w-5 h-5 ease-linear transition-all duration-150 dark:bg-gray-800 dark:border-gray-600"
  end

  defp checkbox_group_layout_classes(assigns) do
    case assigns[:layout] do
      :grid ->
        "grid grid-cols-3 gap-2"

      :row ->
        "flex flex-row gap-4"

      _col ->
        "flex flex-col gap-3"
    end
  end

  defp checkbox_group_layout_item_classes(assigns) do
    case assigns[:layout] do
      :row ->
        "inline-flex items-center block gap-2"

      _col ->
        "inline-flex items-center block gap-3"
    end
  end

  defp switch_classes(has_error) do
    "#{if has_error, do: "has-error", else: ""} absolute w-10 h-5 bg-white border-none rounded-full cursor-pointer peer checked:border-0 checked:bg-transparent checked:focus:bg-transparent checked:hover:bg-transparent dark:bg-gray-800"
  end

  defp radio_classes(has_error) do
    "#{if has_error, do: "has-error", else: ""} border-gray-300 h-4 w-4 cursor-pointer text-primary-600 focus:ring-primary-500 dark:bg-gray-800 dark:border-gray-600"
  end

  defp label_classes(assigns) do
    type_classes =
      if Enum.member?(["checkbox", "radio"], assigns[:type]) do
        ""
      else
        "mb-2 font-medium"
      end

    "#{if field_has_errors?(assigns), do: "has-error", else: ""} #{type_classes} text-sm block text-gray-900 dark:text-gray-200"
  end

  defp field_has_errors?(%{form: form, field: field}) do
    case Keyword.get_values(form.errors, field) do
      [] -> false
      _ -> true
    end
  end

  defp field_has_errors?(_), do: false
end
