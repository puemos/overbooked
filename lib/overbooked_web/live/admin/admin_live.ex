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
    <.header label="Admin" />
    <div class="flex flex-row">
      <div class="space-y-2 w-60 p-6">
        <.link
          navigate={Routes.admin_path(@socket, :users)}
          class={"text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-xs font-medium rounded-md #{if @live_action == :users, do: "bg-gray-200", else: "hover:bg-gray-50"}"}
        >
          Users
        </.link>
        <.link
          navigate={Routes.admin_path(@socket, :rooms)}
          class={"text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-xs font-medium rounded-md #{if @live_action == :rooms, do: "bg-gray-200", else: "hover:bg-gray-50"}"}
        >
          Rooms
        </.link>
        <.link
          navigate={Routes.admin_path(@socket, :desks)}
          class={"text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-xs font-medium rounded-md #{if @live_action == :desks, do: "bg-gray-200", else: "hover:bg-gray-50"}"}
        >
          Desks
        </.link>
      </div>
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
    </div>
    """
  end
end
