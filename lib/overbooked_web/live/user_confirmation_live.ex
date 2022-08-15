defmodule OverbookedWeb.UserConfirmationLive do
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
    <h1>Confirm account</h1>

    <.form for={:user} phx_submit={:confirm}>
      <div>
        <.button label="Confirm my account" type="submit" phx_disable_with="Confirming..." />
      </div>
    </.form>
    <h1>Resend confirmation instructions</h1>

    <.form let={f} for={:user} phx_submit={:resend}>
      <.form_field
        type="email_input"
        form={f}
        required={true}
        field={:email}
        phx_debounce="blur"
        aria_label="Email address"
      />
      <div>
        <.button label="Resend confirmation instructions" type="submit" phx_disable_with="Sending..." />
      </div>
    </.form>

    <p>
      <.link to={Routes.user_session_path(@socket, :new)}>Log in</.link>
      |
      <.link to={Routes.user_reset_password_path(@socket, :new)}>Forgot your password?</.link>
    </p>
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, token: params["token"])}
  end

  def handle_event("resend", %{"user" => user_params}, socket) do
    IO.inspect(user_params)

    if user = Accounts.get_user_by_email(user_params["email"]) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.user_confirmation_url(socket, :new, token: &1)
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

  def handle_event("confirm", _, socket) do
    # Do not log in the user after confirmation to avoid a
    # leaked token giving the user access to the account.
    case Accounts.confirm_user(socket.assigns.token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: "/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(socket, to: "/")

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")}
        end
    end
  end
end
