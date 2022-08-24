defmodule OverbookedWeb.AdminLive do
  use OverbookedWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    users = Overbooked.Accounts.list_users()

    invitations =
      Overbooked.Accounts.list_invitations()
      |> Enum.filter(fn invitation -> invitation.used_by_user == nil end)

    {:ok,
     socket
     |> assign(users: users)
     |> assign(invitations: invitations)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Admin">
      <.tabs>
        <:link active={@live_action == :users} navigate={Routes.admin_path(@socket, :users)}>
          Users
        </:link>
        <:link active={@live_action == :rooms} navigate={Routes.admin_path(@socket, :rooms)}>
          Rooms
        </:link>
        <:link active={@live_action == :desks} navigate={Routes.admin_path(@socket, :desks)}>
          Desks
        </:link>
        <:link active={@live_action == :amenities} navigate={Routes.admin_path(@socket, :amenities)}>
          Amenities
        </:link>
      </.tabs>
    </.header>

    <%= if @live_action == :users do %>
      <.live_component
        current_user={@current_user}
        is_admin={@is_admin}
        module={OverbookedWeb.AdminUsersLive}
        id="admin-users"
      />
    <% end %>
    <%= if @live_action == :rooms do %>
      <.live_component
        current_user={@current_user}
        is_admin={@is_admin}
        module={OverbookedWeb.AdminRoomsLive}
        id="admin-rooms"
      />
    <% end %>
    <%= if @live_action == :desks do %>
      <.live_component
        current_user={@current_user}
        is_admin={@is_admin}
        module={OverbookedWeb.AdminDesksLive}
        id="admin-desks"
      />
    <% end %>
    <%= if @live_action == :amenities do %>
      <.live_component
        current_user={@current_user}
        is_admin={@is_admin}
        module={OverbookedWeb.AdminAmenitiesLive}
        id="admin-amenities"
      />
    <% end %>
    """
  end
end
