defmodule OverbookedWeb.AdminDesksLive do
  use OverbookedWeb, :live_component
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource}
  @impl true
  def mount(socket) do
    desks = Resources.list_desks()
    changelog = Resources.change_resource(%Resource{})

    {:ok,
     socket
     |> assign(desks: desks)
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
              <h3>Desks</h3>
              <.button type="button" phx-click={show_modal("add-desk-modal")}>
                Add desk
              </.button>
              <.modal id="add-desk-modal" on_confirm={hide_modal("add-desk-modal")} icon={nil}>
                <:title>Add a desk</:title>
                <.form
                  :let={f}
                  for={@changelog}
                  phx-submit={:add_desk}
                  phx-change={:validate}
                  id="add-desk-form"
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
                  form="add-desk-form"
                  phx-disable-with="Saving..."
                  variant={:secondary}
                >
                  Save
                </:confirm>

                <:cancel>Cancel</:cancel>
              </.modal>
            </div>
            <.table id="desks" rows={@desks} row_id={fn resource -> "resource-#{resource.id}" end}>
              <:col :let={resource} label="Name" width="w-36"><%= resource.name %></:col>
              <:col :let={resource} label="Color" width="w-24">
                <div class={"bg-#{resource.color}-300 rounded-full h-4 w-4"}></div>
              </:col>
              <:col :let={resource} label="Created at" width="w-46">
                <%= relative_time(resource.inserted_at) %>
              </:col>
              <:col :let={resource} label="">
                <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                  <.button
                    phx-click={show_modal("remove-desk-modal-#{resource.id}")}
                    variant={:danger}
                    size={:small}
                  >
                    Remove
                  </.button>
                  <.button size={:small}>Edit</.button>

                  <.modal
                    id={"remove-desk-modal-#{resource.id}"}
                    on_confirm={
                      JS.push("delete", value: %{id: resource.id}, target: @myself)
                      |> hide_modal("remove-desk-modal-#{resource.id}")
                      |> hide("#resource-#{resource.id}")
                    }
                    icon={nil}
                  >
                    <:title>Remove a desk</:title>
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
  def handle_event("add_desk", %{"resource" => resource_params}, socket) do
    case Resources.create_desk(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Resource created successfully."
         )
         |> push_redirect(to: Routes.admin_path(socket, :desks))}

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
