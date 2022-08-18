defmodule OverbookedWeb.UserResetPasswordLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Reset password</h1>

    <.form let={f} for={@changeset} phx_submit={:reset} id="reset-password-form">
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
      <div>
        <.button label="Reset password" type="submit" phx_disable_with="Reseting..." />
      </div>
    </.form>

    <p>
      <.link to={Routes.login_path(@socket, :index)}>Log in</.link>
    </p>
    """
  end

  def handle_params(params, _uri, socket) do
    token = params["token"]

    if user = Accounts.get_user_by_reset_password_token(token) do
      changeset = Accounts.change_user_password(user)

      {:noreply,
       socket
       |> assign(:user, user)
       |> assign(:token, token)
       |> assign(:changeset, changeset)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Reset password link is invalid or it has expired.")
       |> redirect(to: Routes.login_path(socket, :index))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("reset", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: Routes.login_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
