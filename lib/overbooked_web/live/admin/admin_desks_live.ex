defmodule OverbookedWeb.AdminDesksLive do
  use OverbookedWeb, :live_view
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource}
  @impl true
  def mount(_params, _session, socket) do
    changeset = Resources.change_resource(%Resource{})

    {:ok,
     socket
     |> assign_amenities()
     |> assign_desks()
     |> assign(changeset: changeset)
     |> assign(edit_changeset: changeset)}
  end

  defp assign_amenities(socket) do
    amenities = Resources.list_amenities()
    assign(socket, amenities: amenities)
  end

  defp assign_desks(socket) do
    desks = Resources.list_desks()
    assign(socket, desks: desks)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Admin">
      <.admin_tabs active_tab={@active_tab} socket={@socket} />
    </.header>

    <.modal id="add-resource-modal" on_confirm={hide_modal("add-resource-modal")} icon={nil}>
      <:title>Add a new desk</:title>
      <.form
        :let={f}
        for={@changeset}
        phx-submit={:create}
        phx-change={:validate}
        id="add-resource-form"
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
      </.form>
      <:confirm
        type="submit"
        form="add-resource-form"
        phx-disable-with="Saving..."
        disabled={!@changeset.valid?}
        variant={:secondary}
      >
        Save
      </:confirm>

      <:cancel>Cancel</:cancel>
    </.modal>
    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Desks</h3>
            <.button type="button" phx-click={show_modal("add-resource-modal")}>
              New desk
            </.button>
          </div>
          <.live_table
            module={OverbookedWeb.ResourceRowComponent}
            type="desk"
            id="desks"
            rows={@desks}
            changeset={@edit_changeset}
            amenities={@amenities}
            row_id={fn resource -> "resource-#{resource.id}" end}
          >
            <:col :let={%{resource: resource}} label="Name" width="w-40"><%= resource.name %></:col>
            <:col :let={%{resource: resource}} label="Color" width="w-24">
              <div class={"bg-#{resource.color}-300 rounded-full h-4 w-4"}></div>
            </:col>
            <:col :let={%{resource: resource}} label="Amenities" width="w-24">
              <button
                phx-click={
                  if Enum.count(resource.amenities) > 0,
                    do: show_modal("room-amenities-modal-#{resource.id}")
                }
                disabled={Enum.count(resource.amenities) == 0}
              >
                <.badge color="gray"><%= Enum.count(resource.amenities) %></.badge>
              </button>
            </:col>
            <:col :let={%{resource: resource}} label="">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                <.button
                  phx-click={show_modal("remove-resource-modal-#{resource.id}")}
                  variant={:danger}
                  size={:small}
                >
                  Remove
                </.button>
                <.button
                  phx-click={
                    JS.push("edit", value: %{id: resource.id})
                    |> show_modal("edit-resource-modal-#{resource.id}")
                  }
                  size={:small}
                >
                  Edit
                </.button>
              </div>
            </:col>
          </.live_table>
        </div>
      </div>
    </.page>
    """
  end

  def handle_event("edit", %{"id" => id}, socket) do
    resource = Resources.get_resource!(id)

    edit_changeset =
      resource
      |> Resources.change_resource(%{})

    {:noreply, assign(socket, edit_changeset: edit_changeset)}
  end

  def handle_event("validate_update", %{"resource" => resource_params}, socket) do
    changeset =
      %Resource{}
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, edit_changeset: changeset)}
  end

  @impl true
  def handle_event("update", params, socket) do
    %{"resource" => resource_params, "resource_id" => id} = params
    {:noreply, socket}

    resource = Resources.get_resource!(id)

    case Resources.update_resource(resource, resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource updates successfully."
         )
         |> assign_desks()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, edit_changeset: changeset)}
    end
  end

  def handle_event("validate", %{"resource" => resource_params}, socket) do
    changeset =
      %Resource{}
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"resource" => resource_params}, socket) do
    case Resources.create_desk(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource created successfully."
         )
         |> assign_desks()}

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
