defmodule OverbookedWeb.Nav do
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {OverbookedWeb.HomeLive, _} ->
          :home

        {OverbookedWeb.ScheduleMonthlyLive, _} ->
          :schedule_monthly

        {OverbookedWeb.ScheduleWeeklyLive, _} ->
          :schedule_weekly

        {OverbookedWeb.RoomsLive, _} ->
          :rooms

        {OverbookedWeb.DesksLive, _} ->
          :desks

        {OverbookedWeb.AdminUsersLive, _} ->
          :admin_users

        {OverbookedWeb.AdminDesksLive, _} ->
          :admin_desks

        {OverbookedWeb.AdminRoomsLive, _} ->
          :admin_rooms

        {OverbookedWeb.AdminAmenitiesLive, _} ->
          :admin_amenities

        {OverbookedWeb.UserSettingsLive, _} ->
          :settings

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
