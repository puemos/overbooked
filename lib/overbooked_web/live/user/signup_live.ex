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

    <.form let={f} for={@changeset} phx_change={:validate} phx_submit={:save} id="signup-form">
      <.form_field
        type="email_input"
        form={f}
        required={true}
        field={:email}
        phx_debounce="blur"
        label="Email address"
        aria_label="Email address"
      />
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:password}
        phx_debounce="blur"
        label="Password"
        aria_label="Password"
        value={input_value(f, :password)}
      />
      <.form_field
        type="password_input"
        form={f}
        required={true}
        field={:password_confirmation}
        phx_debounce="blur"
        label="Password confirmation"
        aria_label="Password confirmation"
        value={input_value(f, :password_confirmation)}
      />

      <div>
        <.button label="Register" type="submit" phx_disable_with="Registering..." />
      </div>
    </.form>

    <p>
      <.link to={Routes.login_path(@socket, :index)}>Log in</.link>
      |
      <.link to={Routes.user_forgot_password_path(@socket, :index)}>Forgot your password?</.link>
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
