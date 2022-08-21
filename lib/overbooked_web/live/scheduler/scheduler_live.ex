defmodule OverbookedWeb.SchedulerLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Resources
  alias Overbooked.Scheduler
  alias Overbooked.Scheduler.{Booking}

  @impl true
  def mount(_params, _session, socket) do
    from_date =
      Timex.today()
      |> Timex.beginning_of_month()
      |> Timex.to_naive_datetime()

    to_date =
      Timex.today()
      |> Timex.end_of_month()
      |> Timex.to_naive_datetime()

    bookings = Scheduler.list_bookings(from_date, to_date)

    resources = Resources.list_resources()

    changelog = Scheduler.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(default_day: Timex.format!(Timex.now(), "{YYYY}-{0M}-{D}"))
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(resources: resources)
     |> assign(bookings: bookings)
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Scheduler" />
    <.live_component
      success_path={Routes.scheduler_path(@socket, :index)}
      current_user={@current_user}
      is_admin={@is_admin}
      changelog={@changelog}
      resources={@resources}
      default_day={@default_day}
      module={OverbookedWeb.SchedulerLive.BookingForm}
      id="booking-form"
    />
    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <OverbookedWeb.SchedulerLive.Calendar.calendar
            id="calendar"
            bookings={@bookings}
            beginning_of_month={@from_date}
            end_of_month={@to_date}
          />
        </div>
      </div>
    </.page>
    """
  end

  @impl true
  def handle_event("today", _params, socket) do
    from_date =
      Timex.today()
      |> Timex.beginning_of_month()
      |> Timex.to_naive_datetime()

    to_date =
      Timex.today()
      |> Timex.end_of_month()
      |> Timex.to_naive_datetime()

    bookings = Scheduler.list_bookings(from_date, to_date)

    {:noreply,
     socket
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings: bookings)}
  end

  def handle_event("prev_month", _params, socket) do
    from_date =
      socket.assigns.from_date
      |> Timex.shift(months: -1)
      |> Timex.beginning_of_month()
      |> Timex.to_naive_datetime()

    to_date =
      socket.assigns.to_date
      |> Timex.shift(months: -1)
      |> Timex.end_of_month()
      |> Timex.to_naive_datetime()

    bookings = Scheduler.list_bookings(from_date, to_date)

    {:noreply,
     socket
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings: bookings)}
  end

  def handle_event("day-modal", %{"date" => date}, socket) do
    default_day =
      date
      |> Timex.parse!("{ISO:Extended:Z}")
      |> Timex.format!("{YYYY}-{0M}-{0D}")

    {:noreply,
     socket
     |> assign(default_day: default_day)}
  end

  def handle_event("next_month", _params, socket) do
    from_date =
      socket.assigns.from_date
      |> Timex.shift(months: 1)
      |> Timex.beginning_of_month()
      |> Timex.to_naive_datetime()

    to_date =
      socket.assigns.to_date
      |> Timex.shift(months: 1)
      |> Timex.end_of_month()
      |> Timex.to_naive_datetime()

    bookings = Scheduler.list_bookings(from_date, to_date)

    {:noreply,
     socket
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings: bookings)}
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
