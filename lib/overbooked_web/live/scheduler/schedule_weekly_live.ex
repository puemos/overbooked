defmodule OverbookedWeb.ScheduleWeeklyLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Resources
  alias Overbooked.Schedule
  alias Overbooked.Schedule.{Booking}

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
      Schedule.list_bookings(from_date, to_date, Enum.at(resources, 0))
      |> Schedule.booking_groups(:hourly)

    changeset = Schedule.change_booking(%Booking{})

    {:ok,
     socket
     |> assign(default_day: Timex.format!(Timex.now(), "{YYYY}-{0M}-{0D}"))
     |> assign(default_start_at: "09:00")
     |> assign(default_end_at: "10:00")
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(resources: resources)
     |> assign(resource_id: resource_id)
     |> assign(bookings_hourly: bookings_hourly)
     |> assign(changeset: changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Schedule">
      <.tabs>
        <:link
          active={@active_tab == :schedule_monthly}
          navigate={Routes.schedule_monthly_path(@socket, :index)}
        >
          Monthly
        </:link>
        <:link
          active={@active_tab == :schedule_weekly}
          navigate={Routes.schedule_weekly_path(@socket, :index)}
        >
          Weekly
        </:link>
      </.tabs>
    </.header>
    <.live_component
      success_path={Routes.schedule_weekly_path(@socket, :index)}
      current_user={@current_user}
      is_admin={@is_admin}
      changeset={@changeset}
      resources={@resources}
      default_resource={@resource_id}
      default_day={@default_day}
      default_start_at={@default_start_at}
      default_end_at={@default_end_at}
      module={OverbookedWeb.ScheduleLive.BookingForm}
      id="booking-form"
    />
    <.page full={true}>
      <div class="w-full space-y-12">
        <div class="w-full">
          <OverbookedWeb.ScheduleLive.Calendar.weekly
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
      Schedule.list_bookings(from_date, to_date, resource)
      |> Schedule.booking_groups(:hourly)

    {:noreply,
     socket
     |> assign(resource_id: resource.id)
     |> assign(from_date: from_date)
     |> assign(to_date: to_date)
     |> assign(bookings_hourly: bookings_hourly)}
  end

  def handle_event("filters", %{"resource_id" => resource_id}, socket) do
    from_date = socket.assigns.from_date
    to_date = socket.assigns.to_date

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_weekly_path(socket, :index, %{
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
         Routes.schedule_weekly_path(socket, :index, %{
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
         Routes.schedule_weekly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}"),
           resource_id: socket.assigns.resource_id
         })
     )}
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

    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_weekly_path(socket, :index, %{
           to_date: Timex.format!(to_date, "{ISOdate}"),
           from_date: Timex.format!(from_date, "{ISOdate}"),
           resource_id: socket.assigns.resource_id
         })
     )}
  end

  def handle_event("hour", %{"date" => date, "hour" => default_start_at}, socket) do
    default_end_at =
      default_start_at
      |> Timex.parse!("{h24}:{m}")
      |> Timex.shift(hours: 1)
      |> Timex.format!("{h24}:{m}")

    {:noreply,
     socket
     |> assign(default_day: date)
     |> assign(default_start_at: default_start_at)
     |> assign(default_end_at: default_end_at)}
  end

  def handle_info({:created_booking, _}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.schedule_weekly_path(socket, :index, %{
           to_date: socket.assigns.to_date,
           from_date: socket.assigns.from_date,
           resource_id: socket.assigns.resource_id
         })
     )
     |> put_flash(
       :info,
       "Booking created successfully."
     )}
  end

  def handle_info({:resource_busy, resource}, socket) do
    {:noreply,
     socket
     |> put_flash(
       :error,
       "#{resource.name} is unavailable during those hours"
     )}
  end
end
