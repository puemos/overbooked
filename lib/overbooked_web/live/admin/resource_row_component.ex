defmodule OverbookedWeb.ResourceRowComponent do
  use OverbookedWeb, :live_component

  def render(assigns) do
    ~H"""
    <tr id={@id} class={@class} tabindex="0">
      <.modal
        id={"edit-resource-modal-#{@resource.id}"}
        on_confirm={hide_modal("edit-resource-modal-#{@resource.id}")}
        icon={nil}
      >
        <:title>Edit <%= @resource.name %></:title>
        <.form
          :let={f}
          for={@changeset}
          phx-change={:validate_update}
          phx-submit={:update}
          id={"edit-resource-form-#{@resource.id}"}
        >
          <div class="flex flex-col space-y-4">
            <input class="hidden" type="hidden" value={@resource.id} name="resource_id" />

            <div class="">
              <label for="name" class="block text-sm font-medium text-gray-700">
                Name
              </label>
              <div class="mt-1">
                <.text_input form={f} field={:name} phx_debounce="blur" required={true} />
                <.error form={f} field={:name} />
              </div>
            </div>
            <div class="">
              <label for="color" class="block text-sm font-medium text-gray-700">
                Color
              </label>
              <div class="mt-1">
                <div class="flex gap-x-2">
                  <.select
                    form={f}
                    field={:color}
                    phx_debounce="blur"
                    options={
                      Enum.map(
                        ~w(gray red yellow green blue indigo pink purple),
                        &{String.capitalize(&1), &1}
                      )
                    }
                  />
                </div>
                <.error form={f} field={:color} />
              </div>
            </div>
            <div class="">
              <label for="amenities" class="block text-sm font-medium text-gray-700">
                Amenities
              </label>
              <.checkbox_group
                form={f}
                layout={:grid}
                field={:amenities}
                options={Enum.map(@amenities, &{&1.name, &1.id})}
              />
            </div>
          </div>
        </.form>
        <:confirm
          type="submit"
          form={"edit-resource-form-#{@resource.id}"}
          phx-disable-with="Saving..."
          disabled={!@changeset.valid?}
          variant={:secondary}
        >
          Save
        </:confirm>

        <:cancel>Cancel</:cancel>
      </.modal>
      <.modal id={"room-amenities-modal-#{@resource.id}"} icon={nil}>
        <div class="flex flex-row gap-2 flex-wrap">
          <%= for amenity <- @resource.amenities do %>
            <.badge color="gray"><%= amenity.name %></.badge>
          <% end %>
        </div>
        <:cancel>Close</:cancel>
      </.modal>
      <.modal
        id={"remove-resource-modal-#{@resource.id}"}
        on_confirm={
          JS.push("delete", value: %{id: @resource.id})
          |> hide_modal("remove-resource-modal-#{@resource.id}")
          |> hide("#resource-#{@resource.id}")
        }
        icon={nil}
      >
        <:title>Remove a <%= @type %></:title>
        <span>
          Are you sure you want to remove <span class="font-bold"><%= @resource.name %>?</span>
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
       resource: assigns.row,
       col: assigns.col,
       class: assigns.class,
       index: assigns.index,
       amenities: assigns.amenities,
       type: assigns[:type] || "resource",
       changeset: assigns.changeset
     )}
  end
end
