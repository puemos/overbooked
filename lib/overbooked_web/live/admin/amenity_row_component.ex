defmodule OverbookedWeb.AmenityRowComponent do
  use OverbookedWeb, :live_component

  def render(assigns) do
    ~H"""
    <tr id={@id} class={@class} tabindex="0">
      <.modal
        id={"edit-amenity-modal-#{@amenity.id}"}
        on_confirm={hide_modal("edit-amenity-modal-#{@amenity.id}")}
        icon={nil}
      >
        <:title>Edit Amenity</:title>
        <.form
          :let={f}
          for={@changeset}
          phx-submit={:update}
          phx-change={:validate_update}
          id={"edit-amenity-form-#{@amenity.id}"}
          class="flex flex-col space-y-4"
        >
          <input class="hidden" type="hidden" value={@amenity.id} name="amenity_id" />
          <div class="">
            <label for="name" class="block text-sm font-medium text-gray-700">
              Name
            </label>
            <div class="mt-1">
              <.text_input form={f} field={:name} phx_debounce="blur" required={true} />
              <.error form={f} field={:name} />
            </div>
          </div>
        </.form>
        <:confirm
          type="submit"
          form={"edit-amenity-form-#{@amenity.id}"}
          phx-disable-with="Saving..."
          disabled={!@changeset.valid?}
          variant={:secondary}
        >
          Save
        </:confirm>

        <:cancel>Cancel</:cancel>
      </.modal>
      <.modal
        id={"remove-amenity-modal-#{@amenity.id}"}
        on_confirm={
          JS.push("delete", value: %{id: @amenity.id})
          |> hide_modal("remove-amenity-modal-#{@amenity.id}")
          |> hide("#amenity-#{@amenity.id}")
        }
        icon={nil}
      >
        <:title>Remove an amenity</:title>
        <span>
          Are you sure you want to remove <span class="font-bold"><%= @amenity.name %>?</span>
        </span>
        <:confirm phx-disable-with="Removing..." variant={:danger}>
          Remove
        </:confirm>

        <:cancel>Cancel</:cancel>
      </.modal>
      <%= for {col, i} <- Enum.with_index(@col) do %>
        <td class={"px-6 py-3 text-sm font-medium text-gray-900 #{col[:class]}"}>
          <div class="flex items-center space-x-3 lg:pl-2">
            <%= render_slot(col, assigns) %>
          </div>
        </td>
      <% end %>
    </tr>
    """
  end

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       id: assigns.id,
       amenity: assigns.row,
       col: assigns.col,
       class: assigns.class,
       index: assigns.index,
       changeset: assigns.changeset
     )}
  end
end
