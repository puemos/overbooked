defmodule OverbookedWeb.DesksLive do
  use OverbookedWeb, :live_view
  alias Overbooked.Schedule
  alias Overbooked.Resources
  alias Overbooked.Resources.{Resource}
  @impl true
  def mount(_params, _session, socket) do
    desks = Resources.list_desks()
    changelog = Resources.change_resource(%Resource{})

    {:ok,
     socket
     |> assign(desks: desks)
     |> assign(changelog: changelog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Desks"></.header>

    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="grid grid-cols-4 gap-4">
            <%= for desk <- @desks do %>
              <.desk_card
                name={desk.name}
                color={desk.color}
                amenities={desk.amenities}
                busy={Schedule.resource_busy?(desk, Timex.now(), Timex.now())}
              >
              </.desk_card>
            <% end %>
          </div>
        </div>
      </div>
    </.page>
    """
  end

  defp desk_card(assigns) do
    ~H"""
    <div class="relative px-4 py-2 h-36 border-primary-300 text-primary-700 bg-white hover:bg-primary-50 font-medium items-center border shadow-sm rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500">
      <div class={"absolute top-3 right-3 bg-#{@color}-300 h-2 w-2 rounded-full"}></div>

      <div class="h-full flex flex-col justify-between">
        <div><%= @name %></div>
        <div class="flex flex-row space-x-1">
          <%= for amenity <- @amenities do %>
            <.badge color="gray"><%= amenity.name %></.badge>
          <% end %>
        </div>
        <div>
          <.badge color={if @busy, do: "red", else: "green"}>
            <div class="flex flex-row space-x-1 items-center ">
              <.icon name={if @busy, do: :clock, else: :check_circle} class="w-3 h-3" />
              <span><%= if @busy, do: "Busy", else: "Free" %></span>
            </div>
          </.badge>
        </div>
      </div>
    </div>
    """
  end
end
