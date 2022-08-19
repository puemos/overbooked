defmodule OverbookedWeb.UserSettingsLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:email_changeset, Accounts.change_user_email(user))
     |> assign(:password_changeset, Accounts.change_user_password(user))}
  end

  def render(assigns) do
    ~H"""
    <h1>Settings</h1>

    <h3>Change email</h3>

    <.form :let={f} for={@email_changeset} phx_submit={:change_email} id="change-email-form">
      <div class="">
        <label for="password" class="block text-sm font-medium text-gray-700">
          New email address
        </label>
        <div class="mt-1">
          <.text_input form={f} field={:email} required={true} />
          <.error form={f} field={:email} />
        </div>
      </div>
      <div class="">
        <label for="current_password" class="block text-sm font-medium text-gray-700">
          Password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            field={:current_password}
            value={input_value(f, :current_password)}
            required={true}
            name="current_password"
          />
          <.error form={f} field={:current_password} />
        </div>
      </div>

      <div>
        <.button type="submit" phx_disable_with="Chnaging...">
          Change email
        </.button>
      </div>
    </.form>

    <h3>Change password</h3>

    <.form :let={f} for={@password_changeset} phx_submit={:change_password} id="change-password-form">
      <div class="">
        <label for="password" class="block text-sm font-medium text-gray-700">
          New password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            field={:password}
            value={input_value(f, :password)}
            required={true}
          />
          <.error form={f} field={:password} />
        </div>
      </div>
      <div class="">
        <label for="password_confirmation" class="block text-sm font-medium text-gray-700">
          Confirm new password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            field={:password_confirmation}
            value={input_value(f, :password_confirmation)}
            required={true}
          />
          <.error form={f} field={:password_confirmation} />
        </div>
      </div>
      <div class="">
        <label for="current_password" class="block text-sm font-medium text-gray-700">
          Current password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            field={:current_password}
            value={input_value(f, :current_password)}
            required={true}
            name="current_password"
          />
          <.error form={f} field={:current_password} />
        </div>
      </div>

      <div>
        <.button type="submit" phx_disable_with="Changing...">
          Change password
        </.button>
      </div>
    </.form>
    """
  end

  def handle_event("change_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, password_changeset: changeset)}
    end
  end

  def handle_event("change_email", params, socket) do
    %{"current_password" => password, "user" => %{"email" => email}} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, %{email: email}) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_confirmation_url(socket, :confirm_email, &1)
        )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "A link to confirm your email change has been sent to the new address."
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, email_changeset: changeset)}
    end
  end
end
