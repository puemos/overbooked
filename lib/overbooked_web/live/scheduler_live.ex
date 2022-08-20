defmodule OverbookedWeb.SchedulerLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Resources
  alias Overbooked.Scheduler
  alias Overbooked.Scheduler.{Booking}

  @impl true
  def mount(_params, _session, socket) do
    from_date =
      Timex.today()
      |> Timex.beginning_of_week()
      |> Timex.to_naive_datetime()

    to_date =
      Timex.today()
      |> Timex.end_of_week()
      |> Timex.to_naive_datetime()

    daterange = %{to_date: to_date, from_date: from_date}

    bookings = Scheduler.list_bookings(from_date, to_date)

    resources = Resources.list_resources()

    changelog = Scheduler.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(daterange_changeset: daterange_change(%{}, daterange))
     |> assign(resources: resources)
     |> assign(bookings: bookings)
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Scheduler" />
    <div class="px-4 py-4 sm:px-6 lg:px-8 max-w-4xl w-full">
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Booking</h3>

            <.button type="button" phx-click={show_modal("add-booking-modal")}>
              Add booking
            </.button>
            <.modal id="add-booking-modal" on_confirm={hide_modal("add-booking-modal")} icon={nil}>
              <:title>Add a booking</:title>
              <.form
                :let={f}
                for={@changelog}
                phx-submit={:add_booking}
                phx-change={:validate}
                id="add-booking-form"
                class="flex flex-col space-y-2"
              >
                <div class="flex flex-row space-x-4">
                  <div class="">
                    <label for="start_at" class="block text-sm font-medium text-gray-700">
                      From
                    </label>
                    <div class="mt-1">
                      <.datetime_local_input
                        form={f}
                        field={:start_at}
                        phx_debounce="blur"
                        required={true}
                      />
                      <.error form={f} field={:start_at} />
                    </div>
                  </div>
                  <div class="">
                    <label for="end_at" class="block text-sm font-medium text-gray-700">
                      To
                    </label>
                    <div class="mt-1">
                      <.datetime_local_input
                        form={f}
                        field={:end_at}
                        phx_debounce="blur"
                        required={true}
                      />
                      <.error form={f} field={:end_at} />
                    </div>
                  </div>
                </div>
                <div class="">
                  <label for="start_at" class="block text-sm font-medium text-gray-700">
                    Resource
                  </label>
                  <div class="mt-1">
                    <.select
                      form={f}
                      field={:resource_id}
                      name="resource_id"
                      phx_debounce="blur"
                      options={Enum.map(@resources, &{&1.name, &1.id})}
                      required={true}
                    />
                  </div>
                </div>
              </.form>
              <:confirm
                type="submit"
                form="add-booking-form"
                phx-disable-with="Saving..."
                variant={:secondary}
              >
                Save
              </:confirm>

              <:cancel>Cancel</:cancel>
            </.modal>
          </div>
          <div class="w-full flex flex-row mt-6">
            <.form
                :let={f}
                for={@daterange_changeset}
                as={:daterange}
                phx-change={:daterange}
                id="date-range-form"
                class="flex flex-row space-x-2"
              >
                <.date_input form={f} field={:from_date} />
                <.date_input form={f} field={:to_date} />
              </.form>
            </div>
          <.table id="bookings" rows={@bookings} row_id={fn booking -> "booking-#{booking.id}" end}>
            <:col :let={booking} label="Name" width="w-24"><%= booking.resource.name %></:col>

            <:col :let={booking} label="When" width="w-36">
              <%= from_to_datetime(booking.start_at, booking.end_at) %>
            </:col>

            <:col :let={booking} label="Created at" width="w-36">
              <%= relative_time(booking.inserted_at) %>
            </:col>
            <:col :let={booking} label="Actions" width="w-24">
              <.button
                phx-click={show_modal("remove-booking-modal-#{booking.id}")}
                variant={:danger}
                size={:small}
              >
                Remove
              </.button>

              <.modal
                id={"remove-booking-modal-#{booking.id}"}
                on_confirm={
                  JS.push("delete", value: %{id: booking.id})
                  |> hide_modal("remove-booking-modal-#{booking.id}")
                  |> hide("#booking-#{booking.id}")
                }
                icon={nil}
              >
                <:title>Remove a booking</:title>
                <span>
                  Are you sure you want to remove
                  <span class="font-bold"><%= booking.resource.name %>?</span>
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
    </div>
    """
  end

  @impl true
  def handle_event("daterange", %{"daterange" => daterange_params}, socket) do
    %{"from_date" => from_date, "to_date" => to_date} = daterange_params

    bookings =
      Scheduler.list_bookings(
        Timex.parse!(from_date, "{YYYY}-{M}-{D}"),
        Timex.parse!(to_date, "{YYYY}-{M}-{D}")
      )

    daterange_changeset =
      daterange_change(socket.assigns.daterange_changeset, %{
        to_date: to_date,
        from_date: from_date
      })

    {:noreply,
     socket
     |> assign(bookings: bookings)
     |> assign(daterange_changeset: daterange_changeset)}
  end

  def handle_event("validate", %{"booking" => booking_params}, socket) do
    changeset =
      %Booking{}
      |> Scheduler.change_booking(booking_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "add_booking",
        %{"booking" => booking_params, "resource_id" => resource_id},
        socket
      ) do
    resource = Resources.get_resource!(resource_id)

    case Scheduler.book_resource(resource, socket.assigns.current_user, booking_params) do
      {:ok, _booking} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Booking created successfully."
         )
         |> push_patch(to: Routes.scheduler_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp daterange_change(data, params) do
    types = %{from_date: :date, to_date: :date}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end
end
