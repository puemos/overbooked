defmodule OverbookedWeb.AdminUsersLive do
  use OverbookedWeb, :live_view

  alias Overbooked.Accounts
  alias Overbooked.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_users()
     |> assign_invitations()}
  end

  defp assign_users(socket) do
    users = Overbooked.Accounts.list_users()
    assign(socket, users: users)
  end

  defp assign_invitations(socket) do
    invitations =
      Overbooked.Accounts.list_invitations()
      |> Enum.filter(fn invitation -> invitation.used_by_user == nil end)

    assign(socket, invitations: invitations)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Admin">
      <.admin_tabs active_tab={@active_tab} socket={@socket} />
    </.header>

    <.page>
      <div class="w-full space-y-12">
        <div class="w-full">
          <div class="w-full flex flex-row justify-between">
            <h3>Users</h3>
            <.button type="button" phx-click={show_modal("add-user-modal")}>
              Invite a user
            </.button>
            <.modal id="add-user-modal" on_confirm={hide_modal("add-user-modal")} icon={nil}>
              <:title>Invite a user</:title>
              <.form
                :let={f}
                for={:invitation}
                phx-submit={:invite}
                id="user-invitation-form"
                class="flex flex-col space-y-4"
              >
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
              <:confirm
                type="submit"
                form="user-invitation-form"
                phx-disable-with="Sending..."
                variant={:secondary}
              >
                Invite
              </:confirm>

              <:cancel>Cancel</:cancel>
            </.modal>
          </div>
          <.table id="users" rows={@users} row_id={fn user -> "user-#{user.id}" end}>
            <:col :let={user} label="Name" width="w-24">
              <span class="truncate" title={user.name}><%= user.name %></span>
            </:col>
            <:col :let={user} label="Email" width="w-36">
              <span class="truncate" title={user.email}><%= user.email %></span>
            </:col>
            <:col :let={user} label="Confirmed at" width="w-24">
              <span class="truncate" title={relative_time(user.confirmed_at)}>
                <%= relative_time(user.confirmed_at) %>
              </span>
            </:col>
            <:col :let={user} label="Admin" width="w-24">
              <.form :let={f} for={:admin} phx-change="change-admin">
                <.number_input form={f} field={:user_id} value={user.id} class="hidden" />
                <.switch form={f} field={:admin} checked={user.admin} />
              </.form>
            </:col>

            <:col :let={user} label="" width="w-16">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                <.button
                  phx-click={show_modal("remove-user-modal-#{user.id}")}
                  variant={:danger}
                  size={:small}
                  title={if User.is_admin?(user), do: "You can't delete an admin"}
                  disabled={User.is_admin?(user)}
                >
                  Remove
                </.button>

                <.modal
                  id={"remove-user-modal-#{user.id}"}
                  on_confirm={
                    JS.push("delete-user", value: %{id: user.id})
                    |> hide_modal("remove-user-modal-#{user.id}")
                    |> hide("#user-#{user.id}")
                  }
                  icon={nil}
                >
                  <:title>Remove a user</:title>
                  <span>
                    Are you sure you want to remove <span class="font-bold"><%= user.name %>?</span>
                  </span>
                  <:confirm phx-disable-with="Removing..." variant={:danger}>
                    Remove
                  </:confirm>

                  <:cancel>Cancel</:cancel>
                </.modal>
              </div>
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
            <:col :let={invitation} label="Invited by" width="w-24">
              <span class="truncate" title={invitation.generated_by_user.name}>
                <%= invitation.generated_by_user.name %>
              </span>
            </:col>
            <:col :let={invitation} label="Email" width="w-36">
              <span class="truncate" title={invitation.scoped_to_email}>
                <%= invitation.scoped_to_email %>
              </span>
            </:col>
            <:col :let={invitation} label="Created at" width="w-24">
              <span class="truncate" title={relative_time(invitation.inserted_at)}>
                <%= relative_time(invitation.inserted_at) %>
              </span>
            </:col>
            <:col :let={invitation} label="" width="w-16">
              <div class="w-full flex flex-row-reverse space-x-2 space-x-reverse">
                <.button
                  phx-click={show_modal("remove-invitation-modal-#{invitation.id}")}
                  variant={:danger}
                  size={:small}
                >
                  Remove
                </.button>

                <.modal
                  id={"remove-invitation-modal-#{invitation.id}"}
                  on_confirm={
                    JS.push("delete-invitation", value: %{id: invitation.id})
                    |> hide_modal("remove-invitation-modal-#{invitation.id}")
                    |> hide("#invitation-#{invitation.id}")
                  }
                  icon={nil}
                >
                  <:title>Remove an invitation</:title>
                  <span>
                    Are you sure you want to remove
                    <span class="font-bold"><%= invitation.scoped_to_email %>?</span>
                  </span>
                  <:confirm phx-disable-with="Removing..." variant={:danger}>
                    Remove
                  </:confirm>

                  <:cancel>Cancel</:cancel>
                </.modal>
              </div>
            </:col>
          </.table>
        </div>
      </div>
    </.page>
    """
  end

  @impl true
  def handle_event("invite", %{"invitation" => %{"email" => email}}, socket) do
    Overbooked.Accounts.deliver_user_invitation_instructions(
      socket.assigns.current_user,
      email,
      &Routes.signup_url(socket, :index, &1)
    )

    {:noreply,
     socket
     |> put_flash(
       :info,
       "Your new member will receive instructions to sign up."
     )
     |> assign_invitations()}
  end

  def handle_event("change-admin", %{"admin" => params}, socket) do
    %{"admin" => admin, "user_id" => user_id} = params
    user = Accounts.get_user!(user_id)

    {:ok, _} = Accounts.update_admin(socket.assigns.current_user, user, %{admin: admin})

    {:noreply,
     socket
     |> put_flash(
       :info,
       "#{if user.admin, do: "#{user.name} is no more admin", else: "#{user.name} is now admin"}"
     )
     |> assign_users()}
  end

  def handle_event("delete-user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(socket.assigns.current_user, user)

    {:noreply,
     socket
     |> put_flash(
       :info,
       "#{user.name} was removeed successfully"
     )}
  end

  def handle_event("delete-invitation", %{"id" => id}, socket) do
    registration_token = Accounts.get_registration_token!(id)
    {:ok, _} = Accounts.delete_registration_token(socket.assigns.current_user, registration_token)

    {:noreply, socket}
  end
end
