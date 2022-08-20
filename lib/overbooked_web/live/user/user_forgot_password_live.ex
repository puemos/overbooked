defmodule OverbookedWeb.UserForgotPasswordLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header label="Forgot your password?" />
    <.page>
      <div class="max-w-md mx-auto mt-6">
        <.form
          :let={f}
          for={:user}
          phx-submit={:reset}
          id="forgot-password-form"
          class="flex flex-col space-y-2"
        >
          <div class="">
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <div class="mt-1">
              <.text_input form={f} field={:email} required={true} />
              <.error form={f} field={:email} />
            </div>
          </div>
          <div class="py-2">
            <.button type="submit" phx-disable-with="Sending...">
              Send instructions to reset password
            </.button>
          </div>
        </.form>

        <p>
          <.link class="text-sm" navigate={Routes.login_path(@socket, :index)}>Log in</.link>
        </p>
      </div>
    </.page>
    """
  end

  def handle_event("reset", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &Routes.user_reset_password_url(socket, :index, &1)
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system, you will receive instructions to reset your password shortly."
     )
     |> redirect(to: Routes.login_path(socket, :index))}
  end
end
