defmodule OverbookedWeb.HomeLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Resources
  alias Overbooked.Schedule
  alias Overbooked.Schedule.{Booking}

  @impl true
  def mount(_params, _session, socket) do
    from_date =
      Timex.today()
      |> Timex.to_naive_datetime()

    to_date =
      Timex.today()
      |> Timex.end_of_year()
      |> Timex.to_naive_datetime()

    daterange = %{to_date: to_date, from_date: from_date}

    bookings = Schedule.list_bookings(from_date, to_date, socket.assigns.current_user)

    resources = Resources.list_resources()

    changeset = Schedule.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(daterange_changeset: daterange_change(%{}, daterange))
     |> assign(default_day: Timex.format!(Timex.now(), "{YYYY}-{0M}-{D}"))
     |> assign(resources: resources)
     |> assign(bookings: bookings)
     |> assign(changeset: changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Home"></.header>

    <.live_component
      success_path={Routes.home_path(@socket, :index)}
      current_user={@current_user}
      is_admin={@is_admin}
      changeset={@changeset}
      resources={@resources}
      default_day={@default_day}
      module={OverbookedWeb.ScheduleLive.BookingForm}
      id="booking-form"
    />

    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Upcoming bookings</h3>
            <div class="flex flex-row space-x-2">
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
              <.button type="button" phx-click={show_modal("booking-form-modal")}>
                Book
              </.button>
            </div>
          </div>

          <.table id="bookings" rows={@bookings} row_id={fn booking -> "booking-#{booking.id}" end}>
            <:col :let={booking} label="Place" width="w-16" class="relative">
              <div class="" title={booking.resource.name}>
                <%= booking.resource.name %>
              </div>
              <div class={"absolute left-1 bg-#{booking.resource.color}-300 h-2 w-2 rounded-full"}>
              </div>
            </:col>
            <:col :let={booking} label="Type" width="w-16" class="capitalize">
              <%= booking.resource.resource_type.name %>
            </:col>

            <:col :let={booking} label="When" width="w-36">
              <%= from_to_datetime(booking.start_at, booking.end_at) %>
            </:col>

            <:col :let={booking} label="" width="w-24">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
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
              </div>
            </:col>
          </.table>
        </div>
      </div>
    </.page>
    """
  end

  @impl true
  def handle_event("daterange", %{"daterange" => daterange_params}, socket) do
    %{"from_date" => from_date, "to_date" => to_date} = daterange_params

    bookings =
      Schedule.list_bookings(
        Timex.parse!(from_date, "{YYYY}-{M}-{D}"),
        Timex.parse!(to_date, "{YYYY}-{M}-{D}"),
        socket.assigns.current_user
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
    booking = Schedule.get_booking!(id)

    case Schedule.delete_booking(booking, socket.assigns.current_user) do
      {:ok, _} -> {:noreply, socket}
    end
  end

  defp daterange_change(data, params) do
    types = %{from_date: :date, to_date: :date}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end
end
