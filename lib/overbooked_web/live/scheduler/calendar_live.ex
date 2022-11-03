defmodule OverbookedWeb.ScheduleLive.Calendar do
  use Phoenix.Component

  import OverbookedWeb.LiveHelpers
  import OverbookedWeb.LiveFormHelpers
  alias Phoenix.LiveView.JS

  def weekly(assigns) do
    weekday = Timex.weekday(assigns.end_of_week, :monday)

    hours_of_day =
      Timex.Interval.new(
        from: Timex.beginning_of_day(Timex.now()),
        until: Timex.end_of_day(Timex.now()),
        step: [minutes: 15]
      )
      |> Enum.map(&Timex.format!(&1, "%H:%M", :strftime))

    assigns =
      assigns
      |> assign(:hours_of_day, hours_of_day)
      |> assign(:weekday, weekday)

    ~H"""
    <div class="h-[35rem]">
      <div class="flex items-center mb-8">
        <div class="w-full flex flex-col">
          <div class="w-full flex flex-row mt-6 justify-between">
            <div class="flex flex-row text-xl text-gray-400 font-bold">
              <%= weekly_title(@beginning_of_week, @end_of_week) %>
            </div>
            <div class="flex flex-row space-x-2">
              <.form :let={f} for={:filters} phx-change={:filters}>
                <.select
                  form={f}
                  field={:resource_id}
                  name="resource_id"
                  options={Enum.map(@resources, &{&1.name, &1.id})}
                  required={true}
                  class="py-1.5"
                />
              </.form>
              <.button phx-click="prev_week" size={:narrow}>
                <.icon name={:chevron_left} class="w-4 h-4" />
              </.button>
              <.button phx-click="today">Today</.button>
              <.button phx-click="next_week" size={:narrow}>
                <.icon name={:chevron_right} class="w-4 h-4" />
              </.button>
            </div>
          </div>
        </div>
      </div>
      <div class="text-center grid grid-cols-[50px_repeat(7,1fr)] gap-y-1">
        <div></div>
        <%= for i <- 0..@weekday - 1 do %>
          <.weekday_header index={i} date={Timex.shift(@beginning_of_week, days: i)} />
        <% end %>
      </div>
      <div class="overflow-y-scroll h-full">
        <div class="text-center grid grid-cols-[50px_repeat(7,1fr)] gap-y-1">
          <div>
            <div class="flex flex-col w-full">
              <%= for {hour, _index} <- Enum.with_index(@hours_of_day) do %>
                <div class="h-3 relative">
                  <%= if round_hour?(hour) do %>
                    <div class="absolute -top-1/2 text-xs text-gray-500 h-3 right-2 z-10 flex-col items-center justify-center">
                      <div class="">
                        <%= hour %>
                      </div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
          <%= for i <- 0..@weekday - 1 do %>
            <.weekday
              index={i}
              date={Timex.shift(@beginning_of_week, days: i)}
              bookings_hourly={
                booking_by_day(@bookings_hourly, Timex.shift(@beginning_of_week, days: i))
              }
            />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def weekday_header(%{date: date} = assigns) do
    is_today = Timex.compare(Timex.today(), date, :day) == 0
    weekday = Timex.format!(date, "{D}")
    title = Timex.format!(date, "{WDshort}")

    assigns =
      assigns
      |> assign(:title, title)
      |> assign(:weekday, weekday)
      |> assign(:is_today, is_today)

    ~H"""
    <div class="flex flex-col items-center border-b pb-4">
      <div class="text-xs"><%= @title %></div>
      <div class={"#{if @is_today, do: "bg-purple-500 text-white"} flex flex-col items-center justify-center w-7 h-7 rounded-full text-gray-400 font-bold mt-2"}>
        <div><%= @weekday %></div>
      </div>
    </div>
    """
  end

  defp first_slot?(bookings_hourly, hours_of_day, index) do
    !booking_by_hour(bookings_hourly, Enum.at(hours_of_day, index - 1))
  end

  defp last_slot?(bookings_hourly, hours_of_day, index) do
    !booking_by_hour(bookings_hourly, Enum.at(hours_of_day, index + 1))
  end

  def weekday(%{date: date, bookings_hourly: bookings_hourly} = assigns) do
    older = Timex.compare(Timex.today(), date, :day) == 1
    weekday = Timex.weekday(date, :monday)
    yearday = Timex.day(date)
    title = Timex.format!(date, "{Mfull} {D} {WDfull}")

    hours_of_day =
      Timex.Interval.new(
        from: Timex.beginning_of_day(date),
        until: Timex.end_of_day(date),
        step: [minutes: 15]
      )
      |> Enum.map(&Timex.format!(&1, "%H:%M", :strftime))

    assigns =
      assigns
      |> assign(:text, Timex.format!(date, "{D}"))
      |> assign(:hours_of_day, hours_of_day)
      |> assign(:bookings_hourly, bookings_hourly)
      |> assign(:weekday, weekday)
      |> assign(:yearday, yearday)
      |> assign(:hours_of_day, hours_of_day)
      |> assign(:title, title)
      |> assign(:older, older)

    ~H"""
    <div>
      <div class="flex flex-col w-full border-l">
        <%= for {hour, index} <- Enum.with_index(@hours_of_day) do %>
          <div class={"#{if index !=0 and round_hour?(hour) and first_slot?(@bookings_hourly, @hours_of_day, index), do: "border-t"} #{if booking_by_hour(@bookings_hourly, hour), do: "pr-1"} flex flex-col h-3 w-full relative"}>
            <%= if booking = booking_by_hour(@bookings_hourly, hour) do %>
              <div class={"bg-#{booking.resource.color}-400 #{if first_slot?(@bookings_hourly, @hours_of_day, index), do: "rounded-t-[5px]"} #{if last_slot?(@bookings_hourly, @hours_of_day, index), do: "rounded-b-[5px]"} h-full w-full relative"}>
                <%= if first_slot?(@bookings_hourly, @hours_of_day, index) do %>
                  <div class="text-white text-xs text-left absolute top-0 left-0 p-1 w-full break-all z-10 ">
                    <%= booking.user.name %>
                  </div>
                <% end %>
              </div>
            <% else %>
              <button
                class={"#{if @older, do: "bg-gray-50", else: "hover:bg-gray-100 hover:h-12 absolute top-0 left-0"} top-0 h-full w-full"}
                disabled={@older}
                phx-click={
                  JS.push("hour", value: %{date: Timex.format!(@date, "{YYYY}-{0M}-{0D}"), hour: hour})
                  |> show_modal("booking-form-modal")
                }
              >
              </button>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def monthly(assigns) do
    ~H"""
    <div>
      <div class="flex items-center mb-8">
        <div class="w-full flex flex-row mt-6 justify-between">
          <div class="flex flex-row text-xl text-gray-400 font-bold">
            <%= Timex.format!(@beginning_of_month, "{Mshort} {YYYY}") %>
          </div>
          <div class="flex flex-row space-x-2">
            <.button phx-click="prev_month" size={:narrow}>
              <.icon name={:chevron_left} class="w-4 h-4" />
            </.button>
            <.button phx-click="today">Today</.button>
            <.button phx-click="next_month" size={:narrow}>
              <.icon name={:chevron_right} class="w-4 h-4" />
            </.button>
          </div>
        </div>
      </div>
      <div class="mb-6 text-center grid grid-cols-7 gap-y-1 gap-x-1">
        <div class="text-xs">Mon</div>
        <div class="text-xs">Tue</div>
        <div class="text-xs">Wed</div>
        <div class="text-xs">Thu</div>
        <div class="text-xs">Fri</div>
        <div class="text-xs">Sat</div>
        <div class="text-xs">Sun</div>
        <%= for i <- 0..@end_of_month.day - 1 do %>
          <.day
            index={i}
            date={Timex.shift(@beginning_of_month, days: i)}
            bookings={booking_by_day(@bookings_daily, Timex.shift(@beginning_of_month, days: i))}
          />
        <% end %>
      </div>
    </div>
    """
  end

  def day(%{index: index, date: date} = assigns) do
    older = Timex.compare(Timex.today(), date, :day) == 1
    is_today = Timex.compare(Timex.today(), date, :day) == 0
    weekday = Timex.weekday(date, :monday)
    yearday = Timex.day(date)
    title = Timex.format!(date, "{Mfull} {D} {WDfull}")

    assigns =
      assigns
      |> assign(:text, Timex.format!(date, "{D}"))
      |> assign(:weekday, weekday)
      |> assign(:yearday, yearday)
      |> assign(:title, title)

    ~H"""
    <button
      disabled={older}
      phx-click={show_modal("a-#{@yearday}-modal")}
      class={"#{if index == 0, do: "col-start-#{@weekday}"} #{if is_today, do: "border-purple-500 border-2"} #{if older, do: "bg-gray-50", else: "hover:bg-gray-100"} overflow-hidden h-32 border flex flex-col justify-start items-center text-center"}
    >
      <div class="text-gray-400 font-bold mt-2"><%= @text %></div>
      <div class="flex flex-col space-y-1 mt-2 w-full px-1">
        <%= for booking <- @bookings do %>
          <.event
            user_name={booking.user.name}
            resource_name={booking.resource.name}
            color={booking.resource.color}
          >
          </.event>
        <% end %>
      </div>
    </button>
    <.modal
      id={"a-#{@yearday}-modal"}
      icon={nil}
      on_confirm={
        JS.push("day-modal", value: %{date: date})
        |> hide_modal("a-#{@yearday}-modal")
        |> show_modal("booking-form-modal")
      }
    >
      <:title><%= @title %></:title>

      <%= for booking <- @bookings do %>
        <.event_row
          user_name={booking.user.name}
          resource_name={booking.resource.name}
          color={booking.resource.color}
          time={from_to_datetime(booking.start_at, booking.end_at, :hours)}
        >
        </.event_row>
      <% end %>
      <:confirm>Book</:confirm>
      <:cancel>Close</:cancel>
    </.modal>
    """
  end

  def event(assigns) do
    ~H"""
    <div class="flex flex-row space-x-1 items-center">
      <div class={"bg-#{@color}-300 h-2 w-2 rounded-full"}></div>
      <div class="text-xs truncate" title={"#{@user_name} at #{@resource_name}"}>
        <%= @user_name %> at <%= @resource_name %>
      </div>
    </div>
    """
  end

  def event_row(assigns) do
    ~H"""
    <div class="flex flex-row space-x-2 items-center">
      <div class={"bg-#{@color}-300 h-2 w-2 rounded-full"}></div>
      <div class="text-sm truncate">
        <%= @time %>
      </div>
      <div class="text-sm truncate">
        <%= @user_name %> at <%= @resource_name %>
      </div>
    </div>
    """
  end

  defp booking_by_day(bookings, date) do
    date = Timex.day(date)

    slots = Map.get(bookings, date, %{})

    slots
  end

  defp booking_by_hour(bookings, hour) do
    case Map.get(bookings, hour, []) do
      [booking] -> booking
      _ -> nil
    end
  end

  defp round_hour?(hour) do
    Regex.match?(~r/\d\d:00/, hour)
  end

  defp weekly_title(from_date, to_date) do
    same_year = Timex.compare(from_date, to_date, :year) == 0
    same_month = Timex.compare(from_date, to_date, :month) == 0

    {:ok, from_date_str} = Timex.format(from_date, "{YYYY} {Mshort} {D}")

    {:ok, to_date_str} =
      Timex.format(
        to_date,
        "#{if !same_year, do: "{YYYY}"} #{if !same_month, do: "{Mshort}"} {D}"
      )

    "#{from_date_str} - #{to_date_str}"
  end
end
