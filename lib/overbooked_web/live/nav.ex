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

        {OverbookedWeb.SchedulerLive, _} ->
          :scheduler

        {OverbookedWeb.RoomsLive, _} ->
          :rooms

        {OverbookedWeb.DesksLive, _} ->
          :desks

        {OverbookedWeb.AdminLive, _} ->
          :admin

        {OverbookedWeb.UserSettingsLive, _} ->
          :settings

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
