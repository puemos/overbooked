defmodule OverbookedWeb.AdminRoomsLive do
  use OverbookedWeb, :live_view
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource}
  @impl true
  def mount(_params, _session, socket) do
    changeset = Resources.change_resource(%Resource{})

    {:ok,
     socket
     |> assign_amenities()
     |> assign_rooms()
     |> assign(changeset: changeset)}
  end

  defp assign_amenities(socket) do
    amenities = Resources.list_amenities()
    assign(socket, amenities: amenities)
  end

  defp assign_rooms(socket) do
    rooms = Resources.list_rooms()
    assign(socket, rooms: rooms)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Admin">
      <.tabs>
        <:link
          active={@active_tab == :admin_users}
          navigate={Routes.admin_users_path(@socket, :index)}
        >
          Users
        </:link>
        <:link
          active={@active_tab == :admin_rooms}
          navigate={Routes.admin_rooms_path(@socket, :index)}
        >
          Rooms
        </:link>
        <:link
          active={@active_tab == :admin_desks}
          navigate={Routes.admin_desks_path(@socket, :index)}
        >
          Desks
        </:link>
        <:link
          active={@active_tab == :admin_amenities}
          navigate={Routes.admin_amenities_path(@socket, :index)}
        >
          Amenities
        </:link>
      </.tabs>
    </.header>

    <.modal id="add-room-modal" on_confirm={hide_modal("add-room-modal")} icon={nil}>
      <:title>Add a new room</:title>
      <.form
        :let={f}
        for={@changeset}
        phx-submit={:add_room}
        phx-change={:validate}
        id="add-room-form"
        class="flex flex-col space-y-4"
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
        <div class="flex flex-col space-y-4">
          <label for="amenities" class="block text-sm font-medium text-gray-700">
            Amenities
          </label>
          <.checkbox_group
            layout={:grid}
            form={f}
            field={:amenities}
            options={Enum.map(@amenities, &{&1.name, &1.id})}
          />
        </div>
      </.form>
      <:confirm type="submit" form="add-room-form" phx-disable-with="Saving..." variant={:secondary}>
        Save
      </:confirm>

      <:cancel>Cancel</:cancel>
    </.modal>

    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Rooms</h3>
            <.button type="button" phx-click={show_modal("add-room-modal")}>
              New room
            </.button>
          </div>
          <.table id="rooms" rows={@rooms} row_id={fn resource -> "resource-#{resource.id}" end}>
            <:col :let={resource} label="Name" width="w-36"><%= resource.name %></:col>
            <:col :let={resource} label="Color" width="w-24">
              <div class={"bg-#{resource.color}-300 rounded-full h-4 w-4"}></div>
            </:col>
            <:col :let={resource} label="Amenities" width="w-24">
              <button
                phx-click={
                  if Enum.count(resource.amenities) > 0,
                    do: show_modal("room-amenities-modal-#{resource.id}")
                }
                disabled={Enum.count(resource.amenities) == 0}
              >
                <.badge color="gray"><%= Enum.count(resource.amenities) %></.badge>
              </button>
              <.modal id={"room-amenities-modal-#{resource.id}"} icon={nil}>
                <div class="flex flex-row space-x-1 wrap">
                  <%= for amenity <- resource.amenities do %>
                    <.badge color="gray"><%= amenity.name %></.badge>
                  <% end %>
                </div>
                <:cancel>Close</:cancel>
              </.modal>
            </:col>
            <:col :let={resource} label="Created at" width="w-46">
              <%= relative_time(resource.inserted_at) %>
            </:col>
            <:col :let={resource} label="">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                <.button
                  phx-click={show_modal("remove-room-modal-#{resource.id}")}
                  variant={:danger}
                  size={:small}
                >
                  Remove
                </.button>
                <.button
                  phx-click={show_modal("add-room-amenities-modal-#{resource.id}")}
                  size={:small}
                >
                  Edit
                </.button>

                <.modal
                  id={"remove-room-modal-#{resource.id}"}
                  on_confirm={
                    JS.push("delete", value: %{id: resource.id})
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
              </div>
            </:col>
          </.table>
        </div>
      </div>
    </.page>
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
         |> assign_rooms()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} =
      id
      |> Resources.get_resource!()
      |> Resources.delete_resource()

    {:noreply, socket}
  end
end
