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

    <.form :let={f} for={:user} phx-submit={:resend}>
      <div class="">
        <label for="email" class="block text-sm font-medium text-gray-700">
          Email address
        </label>
        <div class="mt-1">
          <.text_input form={f} field={:email} phx_debounce="blur" required={true} />
          <.error form={f} field={:email} />
        </div>
      </div>

      <div>
        <.button type="submit" phx-disable-with="Sending...">
          Resend confirmation instructions
        </.button>
      </div>
    </.form>

    <p>
      <.link navigate={Routes.login_path(@socket, :index)}>Log in</.link>
      |
      <.link navigate={Routes.user_forgot_password_path(@socket, :index)}>
        Forgot your password?
      </.link>
    </p>
    """
  end

  def handle_event("resend", %{"user" => user_params}, socket) do
    if user = Accounts.get_user_by_email(user_params["email"]) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.user_confirmation_url(socket, :confirm_account, &1)
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
