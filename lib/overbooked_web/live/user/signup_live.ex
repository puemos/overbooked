defmodule OverbookedWeb.SignupLive do
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
    <h1>Sign up</h1>

    <.form :let={f} for={@changeset} phx_change={:validate} phx_submit={:save} id="signup-form">
      <div class="">
        <label for="email" class="block text-sm font-medium text-gray-700">
          Email address
        </label>
        <div class="mt-1">
          <.text_input form={f} field={:email} phx_debounce="blur" required={true} />
          <.error form={f} field={:email} />
        </div>
      </div>
      <div class="">
        <label for="password" class="block text-sm font-medium text-gray-700">
          Password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            phx_debounce="blur"
            field={:password}
            value={input_value(f, :password)}
            required={true}
          />
          <.error form={f} field={:password} />
        </div>
      </div>
      <div class="">
        <label for="password_confirmation" class="block text-sm font-medium text-gray-700">
          Confirm password
        </label>
        <div class="mt-1">
          <.password_input
            form={f}
            phx_debounce="blur"
            field={:password_confirmation}
            value={input_value(f, :password_confirmation)}
            required={true}
          />
          <.error form={f} field={:password_confirmation} />
        </div>
      </div>

      <div>
        <.button type="submit" phx_disable_with="Registering...">Register</.button>
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

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, token: params["token"])}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Overbooked.Accounts.change_user_registration(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user_with_token(socket.assigns.token, user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :confirm_account, &1)
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Account created successfully. Please check your email for confirmation instructions."
         )
         |> redirect(to: Routes.user_resend_confirmation_path(socket, :index))}

      {:error,
       %Ecto.Changeset{errors: [registration_token: {"Invalid registration token!", []}]} =
           changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Your sign up token is invalid, please ask your admin to resend it"
         )
         |> assign(changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
