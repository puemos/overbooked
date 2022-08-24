defmodule OverbookedWeb.AdminAmenitiesLive do
  use OverbookedWeb, :live_component
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource, Amenity}

  @impl true
  def mount(socket) do
    amenities = Resources.list_amenities()
    changelog = Resources.change_amenity(%Amenity{})

    {:ok,
     socket
     |> assign(amenities: amenities)
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
              <h3>Amenities</h3>
              <.button type="button" phx-click={show_modal("add-amenity-modal")}>
                Add amenity
              </.button>
              <.modal id="add-amenity-modal" on_confirm={hide_modal("add-amenity-modal")} icon={nil}>
                <:title>Add an amenity</:title>
                <.form
                  :let={f}
                  for={@changelog}
                  phx-submit={:add_amenity}
                  phx-change={:validate}
                  id="add-amenity-form"
                  phx-target={@myself}
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
                  variant={:secondary}
                >
                  Save
                </:confirm>

                <:cancel>Cancel</:cancel>
              </.modal>
            </div>
            <.table
              id="amenities"
              rows={@amenities}
              row_id={fn amenity -> "amenity-#{amenity.id}" end}
            >
              <:col :let={amenity} label="Name" width="w-52"><%= amenity.name %></:col>

              <:col :let={amenity} label="">
                <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                  <.button
                    phx-click={show_modal("remove-amenity-modal-#{amenity.id}")}
                    variant={:danger}
                    size={:small}
                  >
                    Remove
                  </.button>
                  <.button size={:small}>Edit</.button>

                  <.modal
                    id={"remove-amenity-modal-#{amenity.id}"}
                    on_confirm={
                      JS.push("delete", value: %{id: amenity.id}, target: @myself)
                      |> hide_modal("remove-amenity-modal-#{amenity.id}")
                      |> hide("#amenity-#{amenity.id}")
                    }
                    icon={nil}
                  >
                    <:title>Remove an amenity</:title>
                    <span>
                      Are you sure you want to remove
                      <span class="font-bold"><%= amenity.name %>?</span>
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
    </div>
    """
  end

  def handle_event("validate", %{"amenity" => amenity_params}, socket) do
    changeset =
      %Amenity{}
      |> Resources.change_amenity(amenity_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("add_amenity", %{"amenity" => amenity_params}, socket) do
    case Resources.create_amenity(amenity_params) do
      {:ok, _amenity} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource created successfully."
         )
         |> push_redirect(to: Routes.admin_path(socket, :amenities))}

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
