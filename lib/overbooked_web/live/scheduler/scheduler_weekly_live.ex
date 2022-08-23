defmodule OverbookedWeb.SchedulerWeeklyLive do
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

    resources = Resources.list_resources()
    resource_id = Enum.at(resources, 0).id

    bookings_hourly =
      Scheduler.list_bookings(from_date, to_date, Enum.at(resources, 0))
      |> Scheduler.booking_groups(:hourly)

    changelog = Scheduler.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(default_day: Timex.format!(Timex.now(), "{YYYY}-{0M}-{D}"))
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(resources: resources)
     |> assign(resource_id: resource_id)
     |> assign(bookings_hourly: bookings_hourly)
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Scheduler" />
    <.live_component
      success_path={Routes.scheduler_weekly_path(@socket, :index)}
      current_user={@current_user}
      is_admin={@is_admin}
      changelog={@changelog}
      resources={@resources}
      default_day={@default_day}
      module={OverbookedWeb.SchedulerLive.BookingForm}
      id="booking-form"
    />
    <.page full={true}>
      <div class="w-full space-y-12">
        <div class="w-full">
          <OverbookedWeb.SchedulerLive.Calendar.weekly
            id="calendar"
            resources={@resources}
            bookings_hourly={@bookings_hourly}
            beginning_of_week={@from_date}
            end_of_week={@to_date}
          />
        </div>
      </div>
    </.page>
    """
  end

  def handle_params(params, _uri, socket) do
    maybe_from_date = Map.get(params, "from_date")
    maybe_to_date = Map.get(params, "to_date")
    maybe_resource_id = Map.get(params, "resource_id")

    resources = socket.assigns.resources

    default_from_date =
      Timex.today()
      |> Timex.beginning_of_week()
      |> Timex.to_naive_datetime()

    default_to_date =
      Timex.today()
      |> Timex.end_of_week()
      |> Timex.to_naive_datetime()

    from_date =
      case Timex.parse(maybe_from_date, "{ISOdate}") do
        {:ok, date} -> date
        {:error, _} -> default_from_date
      end

    to_date =
      case Timex.parse(maybe_to_date, "{ISOdate}") do
        {:ok, date} -> date
        {:error, _} -> default_to_date
      end

    resource =
      case maybe_resource_id do
        nil -> Enum.at(resources, 0)
        id -> Enum.find(resources, fn r -> r.id == String.to_integer(id) end)
      end

    bookings_hourly =
      Scheduler.list_bookings(from_date, to_date, resource)
      |> Scheduler.booking_groups(:hourly)

    {:noreply,
     socket
     |> assign(resource_id: resource.id)
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings_hourly: bookings_hourly)}
  end

  def handle_event("selected_resource", %{"resource_id" => resource_id}, socket) do
    from_date = socket.assigns.from_date
    to_date = socket.assigns.to_date

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.scheduler_weekly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}"),
           resource_id: resource_id
         })
     )}
  end

  @impl true
  def handle_event("today", _params, socket) do
    from_date =
      Timex.today()
      |> Timex.beginning_of_week()
      |> Timex.to_naive_datetime()

    to_date =
      Timex.today()
      |> Timex.end_of_week()
      |> Timex.to_naive_datetime()

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.scheduler_weekly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}"),
           resource_id: socket.assigns.resource_id
         })
     )}
  end

  def handle_event("prev_week", _params, socket) do
    from_date =
      socket.assigns.from_date
      |> Timex.shift(days: -7)
      |> Timex.beginning_of_week()
      |> Timex.to_naive_datetime()

    to_date =
      socket.assigns.to_date
      |> Timex.shift(days: -7)
      |> Timex.end_of_week()
      |> Timex.to_naive_datetime()

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.scheduler_weekly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}"),
           resource_id: socket.assigns.resource_id
         })
     )}
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

  def handle_event("next_week", _params, socket) do
    from_date =
      socket.assigns.from_date
      |> Timex.shift(days: 7)
      |> Timex.beginning_of_week()
      |> Timex.to_naive_datetime()

    to_date =
      socket.assigns.to_date
      |> Timex.shift(days: 7)
      |> Timex.end_of_week()
      |> Timex.to_naive_datetime()

    bookings_hourly =
      Scheduler.list_bookings(from_date, to_date)
      |> Scheduler.booking_groups(:hourly)

    {:noreply,
     socket
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings_hourly: bookings_hourly)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    booking = Scheduler.get_booking!(id)

    case Scheduler.delete_booking(booking, socket.assigns.current_user) do
      {:ok, _} -> {:noreply, socket}
    end
  end
end
