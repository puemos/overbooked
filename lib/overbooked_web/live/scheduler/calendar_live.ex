defmodule OverbookedWeb.SchedulerLive.Calendar do
  use Phoenix.Component

  import OverbookedWeb.LiveHelpers
  alias Phoenix.LiveView.JS

  def calendar(assigns) do
    ~H"""
    <div>
      <div class="flex items-center mb-8">
        <div class="w-full flex flex-row mt-6 justify-between">
          <div class="flex flex-row text-xl text-gray-400 font-bold">
            <%= Timex.format!(@beginning_of_month, "{Mshort} {YYYY}") %>
          </div>
          <div class="flex flex-row space-x-2">
            <.button phx-click="prev_month">Prev</.button>
            <.button phx-click="next_month">Next</.button>
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
            bookings={booking_by_day(@bookings, Timex.shift(@beginning_of_month, days: i))}
          />
        <% end %>
      </div>
    </div>
    """
  end

  def day(%{index: index, date: date} = assigns) do
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
      phx-click={show_modal("a-#{@yearday}-modal")}
      class={"#{if index == 0, do: "col-start-#{@yearday}"} overflow-hidden h-32 border flex flex-col justify-start items-center text-center"}
    >
      <div class="text-gray-400 font-bold mt-2"><%= @text %></div>
      <div class="flex flex-col space-y-1 mt-2 bg-white w-full px-1">
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
      <div class="text-xs truncate">
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
    date = Timex.to_naive_datetime(date)

    bookings
    |> Enum.filter(fn booking ->
      booking_interval =
        Timex.Interval.new(from: booking.start_at, until: booking.end_at, step: [minutes: 15])

      date_interval =
        Timex.Interval.new(
          from: Timex.to_naive_datetime(Timex.beginning_of_day(date)),
          until: Timex.to_naive_datetime(Timex.end_of_day(date)),
          step: [minutes: 15]
        )

      Timex.Interval.overlaps?(booking_interval, date_interval)
    end)
  end
end
