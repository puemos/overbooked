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
        <div class="px-4 py-4 sm:px-6 lg:px-8 max-w-4xl w-full">
          <div class="w-full space-y-12">
            <div class="w-full">
              <div class="w-full flex flex-row justify-between">
                <h3>Members</h3>
                <.button type="button" phx-click={show_modal("add-user-modal")}>
                  Add user
                </.button>
                <.modal id="add-user-modal" on_confirm={hide_modal("add-user-modal")} icon={nil}>
                  <:title>Invite a user</:title>
                  <.form :let={f} for={:invitation} phx-submit={:invite} id="user-invitation-form">
                    <div class="">
                      <label for="email" class="block text-sm font-medium text-gray-700">
                        Email address
                      </label>
                      <div class="mt-1">
                        <.text_input form={f} field={:email} phx_debounce="blur" required={true} />
                        <.error form={f} field={:email} />
                      </div>
                    </div>
                  </.form>
                  <:confirm type="submit" form="user-invitation-form" phx-disable-with="Sending...">
                    Invite
                  </:confirm>

                  <:cancel>Cancel</:cancel>
                </.modal>
              </div>
              <.table id="users" rows={@users} row_id={fn user -> "user-#{user.id}" end}>
                <:col :let={user} label="Name"><%= user.name %></:col>
                <:col :let={user} label="Email"><%= user.email %></:col>
                <:col :let={user} label="Confirmed at">
                  <%= relative_time(user.confirmed_at) %>
                </:col>
              </.table>
            </div>

            <div>
              <h3>Pending invitations</h3>

              <.table
                id="invitations"
                rows={@invitations}
                row_id={fn invitation -> "invitation-#{invitation.id}" end}
              >
                <:col :let={invitation} label="Invited by">
                  <%= invitation.generated_by_user.name %>
                </:col>
                <:col :let={invitation} label="Email">
                  <%= invitation.scoped_to_email %>
                </:col>
                <:col :let={invitation} label="Created at">
                  <%= relative_time(invitation.inserted_at) %>
                </:col>
              </.table>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("invite", %{"invitation" => %{"email" => email}}, socket) do
    res =
      Overbooked.Accounts.deliver_user_invitation_instructions(
        socket.assigns.current_user,
        email,
        &Routes.signup_url(socket, :index, &1)
      )

    IO.inspect(res)

    {:noreply,
     socket
     |> put_flash(
       :info,
       "Your new member will receive instructions to sign up."
     )}
  end
end
