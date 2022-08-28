defmodule OverbookedWeb.AdminAmenitiesLive do
  use OverbookedWeb, :live_view
  alias Overbooked.Resources
  alias Overbooked.Resources.{Amenity}

  @impl true
  def mount(_params, _session, socket) do
    changeset = Resources.change_amenity(%Amenity{})

    {:ok,
     socket
     |> assign_amenities()
     |> assign(changeset: changeset)
     |> assign(edit_changeset: changeset)}
  end

  defp assign_amenities(socket) do
    amenities = Resources.list_amenities()
    assign(socket, amenities: amenities)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Admin">
      <.admin_tabs active_tab={@active_tab} socket={@socket} />
    </.header>

    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Amenities</h3>
            <.button type="button" phx-click={show_modal("add-amenity-modal")}>
              New amenity
            </.button>

            <.modal id="add-amenity-modal" on_confirm={hide_modal("add-amenity-modal")} icon={nil}>
              <:title>Add a new amenity</:title>
              <.form
                :let={f}
                for={@changeset}
                phx-submit={:create}
                phx-change={:validate}
                id="add-amenity-form"
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
              </.form>
              <:confirm
                type="submit"
                form="add-amenity-form"
                phx-disable-with="Saving..."
                disabled={!@changeset.valid?}
                variant={:secondary}
              >
                Save
              </:confirm>

              <:cancel>Cancel</:cancel>
            </.modal>
          </div>
          <.live_table
            module={OverbookedWeb.AmenityRowComponent}
            id="amenities"
            rows={@amenities}
            changeset={@edit_changeset}
            row_id={fn amenity -> "amenity-#{amenity.id}" end}
          >
            <:col :let={%{amenity: amenity}} label="Name" width="w-52"><%= amenity.name %></:col>

            <:col :let={%{amenity: amenity}} label="">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                <.button
                  phx-click={show_modal("remove-amenity-modal-#{amenity.id}")}
                  variant={:danger}
                  size={:small}
                >
                  Remove
                </.button>
                <.button
                  phx-click={
                    JS.push("edit", value: %{id: amenity.id})
                    |> show_modal("edit-amenity-modal-#{amenity.id}")
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
    amenity = Resources.get_amenity!(id)

    edit_changeset =
      amenity
      |> Resources.change_amenity(%{})
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, edit_changeset: edit_changeset)}
  end

  def handle_event("validate_update", %{"amenity" => amenity_params}, socket) do
    changeset =
      %Amenity{}
      |> Resources.change_amenity(amenity_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, edit_changeset: changeset)}
  end

  @impl true
  def handle_event("update", %{"amenity" => amenity_params, "amenity_id" => id}, socket) do
    amenity = Resources.get_amenity!(id)

    case Resources.update_amenity(amenity, amenity_params) do
      {:ok, _amenity} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource updates successfully."
         )
         |> assign_amenities()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, edit_changeset: changeset)}
    end
  end

  def handle_event("validate", %{"amenity" => amenity_params}, socket) do
    changeset =
      %Amenity{}
      |> Resources.change_amenity(amenity_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"amenity" => amenity_params}, socket) do
    case Resources.create_amenity(amenity_params) do
      {:ok, _amenity} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource created successfully."
         )
         |> assign_amenities()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} =
      id
      |> Resources.get_amenity!()
      |> Resources.delete_amenity()

    {:noreply, socket}
  end
end
