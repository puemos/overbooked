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

    <.form let={f} for={@email_changeset} phx_submit={:update_email}>
      <.form_field
        type="email_input"
        form={f}
        required={true}
        field={:email}
        label="New email"
        aria_label="New email"
      />
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:current_password}
        label="Password"
        aria_label="Password"
        value={input_value(f, :current_password)}
      />
      <div>
        <.button label="Change email" type="submit" phx_disable_with="Chnaging..." />
      </div>
    </.form>

    <h3>Change password</h3>

    <.form let={f} for={@password_changeset} phx_submit={:update_password}>
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:password}
        phx_debounce="blur"
        label="New password"
        aria_label="New password"
        value={input_value(f, :password)}
      />
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:password_confirmation}
        phx_debounce="blur"
        label="Confirm new password"
        aria_label="Confirm new password"
        value={input_value(f, :password_confirmation)}
      />
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:current_password}
        phx_debounce="blur"
        label="Current password"
        aria_label="Current password"
        value={input_value(f, :current_password)}
      />
      <div>
        <.button label="Change password" type="submit" phx_disable_with="Changing..." />
      </div>
    </.form>
    """
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")
         |> redirect(to: Routes.sign_in_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, password_changeset: changeset)}
    end
  end

  def handle_event("update_email", %{"user" => params}, socket) do
    %{"current_password" => password, "email" => email} = params
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
        IO.inspect(changeset)
        {:noreply, assign(socket, email_changeset: changeset)}
    end
  end
end
