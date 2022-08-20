defmodule OverbookedWeb.AdminRoomsLive do
  use OverbookedWeb, :live_component
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource}
  @impl true
  def mount(socket) do
    resources = Resources.list_rooms()
    changelog = Resources.change_resource(%Resource{})

    {:ok,
     socket
     |> assign(resources: resources)
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.page>
        <div class="w-full space-y-12">
          <div class="w-full">
            <div class="w-full flex flex-row justify-between">
              <h3>Rooms</h3>
              <.button type="button" phx-click={show_modal("add-room-modal")}>
                Add room
              </.button>
              <.modal id="add-room-modal" on_confirm={hide_modal("add-room-modal")} icon={nil}>
                <:title>Add a room</:title>
                <.form
                  :let={f}
                  for={@changelog}
                  phx-submit={:add_room}
                  phx-change={:validate}
                  id="add-room-form"
                  phx-target={@myself}
                  class="flex flex-col space-y-2"
                >
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
                </.form>
                <:confirm
                  type="submit"
                  form="add-room-form"
                  phx-disable-with="Saving..."
                  variant={:secondary}
                >
                  Save
                </:confirm>

                <:cancel>Cancel</:cancel>
              </.modal>
            </div>
            <.table
              id="resources"
              rows={@resources}
              row_id={fn resource -> "resource-#{resource.id}" end}
            >
              <:col :let={resource} label="Name" width="w-36"><%= resource.name %></:col>
              <:col :let={resource} label="Color" width="w-24">
                <div class={"bg-#{resource.color}-300 rounded-full h-4 w-4"}></div>
              </:col>
              <:col :let={resource} label="Created at" width="w-46">
                <%= relative_time(resource.inserted_at) %>
              </:col>
              <:col :let={resource} label="Actions">
                <.button
                  phx-click={show_modal("remove-room-modal-#{resource.id}")}
                  variant={:danger}
                  size={:small}
                >
                  Remove
                </.button>
                <.button size={:small}>Edit</.button>

                <.modal
                  id={"remove-room-modal-#{resource.id}"}
                  on_confirm={
                    JS.push("delete", value: %{id: resource.id}, target: @myself)
                    |> hide_modal("remove-room-modal-#{resource.id}")
                    |> hide("#resource-#{resource.id}")
                  }
                  icon={nil}
                >
                  <:title>Remove a room</:title>
                  <span>
                    Are you sure you want to remove
                    <span class="font-bold"><%= resource.name %>?</span>
                  </span>
                  <:confirm phx-disable-with="Removing..." variant={:danger}>
                    Remove
                  </:confirm>

                  <:cancel>Cancel</:cancel>
                </.modal>
              </:col>
            </.table>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  def handle_event("validate", %{"resource" => resource_params}, socket) do
    changeset =
      %Resource{}
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("add_room", %{"resource" => resource_params}, socket) do
    case Resources.create_room(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource created successfully."
         )
         |> push_redirect(to: Routes.admin_path(socket, :rooms))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    :ok =
      id
      |> Resources.get_resource!()
      |> Resources.delete_resource()

    {:noreply, socket}
  end
end
