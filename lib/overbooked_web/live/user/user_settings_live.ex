defmodule OverbookedWeb.UserSettingsLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_password(socket.assigns.current_user)
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <h1>Reset password</h1>

    <.form let={f} for={@changeset} phx_change={:validate} phx_submit={:reset}>
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
      <.link to={Routes.sign_in_path(@socket, :index)}>Log in</.link>
    </p>
    """
  end

  def handle_params(params, _uri, socket) do
    token = params["token"]

    if user = Accounts.get_user_by_reset_password_token(token) do
      {:noreply, socket |> assign(:user, user) |> assign(:token, token)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Reset password link is invalid or it has expired.")
       |> redirect(to: "/")}
    end
  end

  def handle_event("reset", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: Routes.sign_in_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end


end
