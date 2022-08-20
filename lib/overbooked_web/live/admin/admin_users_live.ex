defmodule OverbookedWeb.AdminUsersLive do
  use OverbookedWeb, :live_component

  alias Overbooked.Accounts
  alias Overbooked.Accounts.User

  @impl true
  def mount(socket) do
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
    <div class="px-4 py-4 sm:px-6 lg:px-8 max-w-4xl w-full">
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
                phx-target={@myself}
                id="user-invitation-form"
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
            <:col :let={user} label="Actions" width="w-16">
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
                  JS.push("delete-user", value: %{id: user.id}, target: @myself)
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
            <:col :let={invitation} label="Actions" width="w-16">
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
                  JS.push("delete-invitation", value: %{id: invitation.id}, target: @myself)
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
            </:col>
          </.table>
        </div>
      </div>
    </div>
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
     |> push_patch(to: Routes.admin_path(socket, :users))}
  end

  def handle_event("delete-user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(socket.assigns.current_user, user)

    {:noreply, socket}
  end

  def handle_event("delete-invitation", %{"id" => id}, socket) do
    registration_token = Accounts.get_registration_token!(id)
    {:ok, _} = Accounts.delete_registration_token(socket.assigns.current_user, registration_token)

    {:noreply, socket}
  end
end
