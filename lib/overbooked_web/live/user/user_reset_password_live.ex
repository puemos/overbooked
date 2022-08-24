defmodule OverbookedWeb.UserResetPasswordLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  alias Overbooked.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header label="Reset password"></.header>
    <.page>
      <div class="max-w-md mt-6">
        <.form
          :let={f}
          for={@changeset}
          phx-submit={:reset}
          id="reset-password-form"
          class="flex flex-col space-y-4"
        >
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

          <div class="py-2">
            <.button type="submit" phx-disable-with="Reseting...">
              Reset password
            </.button>
          </div>
        </.form>

        <p class="mt-2">
          <.link class="text-sm" navigate={Routes.login_path(@socket, :index)}>Log in</.link>
        </p>
      </div>
    </.page>
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
