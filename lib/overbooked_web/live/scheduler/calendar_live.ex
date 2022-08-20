defmodule OverbookedWeb.SchedulerLive.Calendar do
  use Phoenix.Component

  def calendar(assigns) do
    ~H"""
    <div>
      <div class="flex items-center mb-8">
        <div class="flex-1">
          <%= Timex.format!(@beginning_of_month, "{Mshort} {YYYY}") %>
        </div>
      </div>
      <div class="mb-6 text-center calendar grid grid-cols-7 gap-y-1 gap-x-1">
        <div class="text-xs">Mon</div>
        <div class="text-xs">Tue</div>
        <div class="text-xs">Wed</div>
        <div class="text-xs">Thu</div>
        <div class="text-xs">Fri</div>
        <div class="text-xs">Sat</div>
        <div class="text-xs">Sun</div>
        <%= for i <- 0..@end_of_month.day - 1 do %>
          <.day index={i} date={Timex.shift(@beginning_of_month, days: i)} />
        <% end %>
      </div>
    </div>
    """
  end

  def day(%{index: index, date: date} = assigns) do
    weekday = Timex.weekday(date, :monday)

    assigns =
      assigns
      |> assign(:text, Timex.format!(date, "{D}"))

    ~H"""
    <div class={"#{if index == 0, do: "col-start-#{weekday}"} h-24 border flex flex-col justify-start items-center flex text-center"}>
      <div><%= @text %></div>
      <div>
        <.event user_name="Shy" resource_name="Room A"></.event>
      </div>
    </div>
    """
  end

  def event(assigns) do
    ~H"""
    <div class="text-xs bg-purple-300 px-2 rounded-xl"><%= @user_name %> <%= @resource_name %></div>
    """
  end
end
