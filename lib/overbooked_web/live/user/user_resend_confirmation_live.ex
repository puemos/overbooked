defmodule OverbookedWeb.UserResendConfirmationLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts
  alias Overbooked.Accounts.User

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <h1>Resend confirmation instructions</h1>

    <.form let={f} for={:user} phx_submit={:resend}>
      <.form_field
        type="email_input"
        form={f}
        required={true}
        field={:email}
        phx_debounce="blur"
        label="Email address"
        aria_label="Email address"
      />
      <div>
        <.button label="Resend confirmation instructions" type="submit" phx_disable_with="Sending..." />
      </div>
    </.form>

    <p>
      <.link to={Routes.sign_in_path(@socket, :index)}>Log in</.link>
      |
      <.link to={Routes.user_forgot_password_path(@socket, :index)}>Forgot your password?</.link>
    </p>
    """
  end

  def handle_event("resend", %{"user" => user_params}, socket) do
    if user = Accounts.get_user_by_email(user_params["email"]) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.user_confirmation_url(socket, :confirm_account, token: &1)
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system and it has not been confirmed yet, " <>
         "you will receive an email with instructions shortly."
     )}
  end
end
