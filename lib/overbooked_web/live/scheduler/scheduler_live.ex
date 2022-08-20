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

            <.button type="button" phx-click={show_modal("booking-form-modal")}>
              Book
            </.button>
            <.live_component
              success_path={Routes.scheduler_path(@socket, :index)}
              current_user={@current_user}
              is_admin={@is_admin}
              changelog={@changelog}
              resources={@resources}
              module={OverbookedWeb.SchedulerLive.BookingForm}
              id="booking-form"
            />
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
          <OverbookedWeb.SchedulerLive.Calendar.calendar
            id="calendar"
            end_of_month={Timex.end_of_month(Timex.shift(Timex.today(), months: 2))}
            beginning_of_month={Timex.beginning_of_month(Timex.shift(Timex.today(), months: 2))}
          />
          <.table rows={@bookings} row_id={fn booking -> "booking-#{booking.id}" end}>
            <:col :let={booking} label="Resource" width="w-16"><%= booking.resource.name %></:col>
            <:col :let={booking} label="Booked by" width="w-24"><%= booking.user.name %></:col>
            <:col :let={booking} label="Type" width="w-16" class="capitalize">
              <%= booking.resource.resource_type.name %>
            </:col>

            <:col :let={booking} label="When" width="w-36">
              <%= from_to_datetime(booking.start_at, booking.end_at) %>
            </:col>

            <:col :let={booking} label="Actions" width="w-24">
              <.button
                phx-click={show_modal("remove-booking-modal-#{booking.id}")}
                variant={:danger}
                size={:small}
                disabled={@current_user.id != booking.user.id and !@is_admin}
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

  def handle_event("delete", %{"id" => id}, socket) do
    booking = Scheduler.get_booking!(id)

    case Scheduler.delete_booking(booking, socket.assigns.current_user) do
      {:ok, _} -> {:noreply, socket}
    end
  end

  defp daterange_change(data, params) do
    types = %{from_date: :date, to_date: :date}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end
end
