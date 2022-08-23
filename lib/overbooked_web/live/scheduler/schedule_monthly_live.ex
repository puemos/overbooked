defmodule OverbookedWeb.ScheduleMonthlyLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Resources
  alias Overbooked.Schedule
  alias Overbooked.Schedule.{Booking}

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

    resources = Resources.list_resources()

    changelog = Schedule.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(default_day: Timex.format!(Timex.now(), "{YYYY}-{0M}-{D}"))
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(resources: resources)
     |> assign(bookings_daily: [])
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Schedule">
      <div class="flex flex-row space-x-2">
        <.link
          navigate={Routes.schedule_weekly_path(@socket, :index)}
          class={"text-gray-700 hover:text-gray-900 group flex items-center px-2 py-1.5 text-sm font-medium rounded-md #{if @active_tab == :schedule_weekly, do: "bg-gray-200", else: "hover:bg-gray-50"}"}
        >
          Weekly
        </.link>
        <.link
          navigate={Routes.schedule_monthly_path(@socket, :index)}
          class={"text-gray-700 hover:text-gray-900 group flex items-center px-2 py-1.5 text-sm font-medium rounded-md #{if @active_tab == :schedule_monthly, do: "bg-gray-200", else: "hover:bg-gray-50"}"}
        >
          Monthly
        </.link>
      </div>
    </.header>

    <.live_component
      success_path={
        Routes.schedule_monthly_path(@socket, :index, %{
          to_date: Timex.format!(@to_date, "{ISOdate}"),
          from_date: Timex.format!(@from_date, "{ISOdate}")
        })
      }
      current_user={@current_user}
      is_admin={@is_admin}
      changelog={@changelog}
      resources={@resources}
      default_day={@default_day}
      module={OverbookedWeb.ScheduleLive.BookingForm}
      id="booking-form"
    />
    <.page full={true}>
      <div class="w-full space-y-12">
        <div class="w-full">
          <OverbookedWeb.ScheduleLive.Calendar.monthly
            id="calendar"
            bookings_daily={@bookings_daily}
            beginning_of_month={@from_date}
            end_of_month={@to_date}
          />
        </div>
      </div>
    </.page>
    """
  end

  def handle_params(params, _uri, socket) do
    default_from_date =
      Timex.today()
      |> Timex.beginning_of_month()
      |> Timex.to_naive_datetime()

    default_to_date =
      Timex.today()
      |> Timex.end_of_month()
      |> Timex.to_naive_datetime()

    maybe_from_date = Map.get(params, "from_date")
    maybe_to_date = Map.get(params, "to_date")

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

    bookings_daily =
      Schedule.list_bookings(from_date, to_date)
      |> Schedule.booking_groups(:daily)

    {:noreply,
     socket
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings_daily: bookings_daily)}
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

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_monthly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}")
         })
     )}
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

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_monthly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}")
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

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_monthly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}")
         })
     )}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    booking = Schedule.get_booking!(id)

    case Schedule.delete_booking(booking, socket.assigns.current_user) do
      {:ok, _} -> {:noreply, socket}
    end
  end
end
