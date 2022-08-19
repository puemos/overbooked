defmodule OverbookedWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Phoenix.LiveView
  alias Overbooked.Accounts
  alias Overbooked.Accounts.{User}
  alias OverbookedWeb.Router.Helpers, as: Routes

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    case session do
      %{"user_token" => _} ->
        {:halt,
         socket
         |> LiveView.redirect(to: Routes.home_path(socket, :index))}

      %{} ->
        {:cont,
         socket
         |> LiveView.assign(:current_user, nil)
         |> LiveView.assign(:is_admin, nil)}
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session do
      %{"user_token" => user_token} ->
        new_socket =
          socket
          |> LiveView.assign_new(:current_user, fn ->
            Accounts.get_user_by_session_token(user_token)
          end)
          |> LiveView.assign_new(:is_admin, fn %{current_user: current_user} ->
            User.is_admin?(current_user)
          end)

        case new_socket.assigns.current_user do
          %User{confirmed_at: nil} ->
            {:halt,
             socket
             |> Phoenix.LiveView.Utils.put_flash(
               :info,
               "To log in, please confirm your email address"
             )
             |> redirect_require_login()}

          %User{confirmed_at: _} ->
            {:cont, new_socket}
        end

      %{} ->
        {:halt, redirect_require_login(socket)}
    end
  rescue
    Ecto.NoResultsError -> {:halt, redirect_require_login(socket)}
  end

  defp redirect_require_login(socket) do
    socket
    |> LiveView.put_flash(:error, "Please sign in")
    |> LiveView.redirect(to: Routes.login_path(socket, :index))
  end

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_overbooked_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so Overbooked sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using Overbooked.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      OverbookedWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: Routes.login_path(conn, :index))
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    is_admin = User.is_admin?(user)

    conn
    |> assign(:current_user, user)
    |> assign(:is_admin, is_admin)
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_admin_user(conn, _opts) do
    user = conn.assigns[:current_user]

    if user and User.is_admin?(%User{email: user.email}) do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access this page.")
      |> redirect(to: Routes.home_path(conn, :index))
      |> halt()
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    user = conn.assigns[:current_user]

    case user do
      %User{confirmed_at: nil} ->
        conn
        |> put_flash(:error, "To log in, please confirm your email address")
        |> maybe_store_return_to()
        |> redirect(to: Routes.user_resend_confirmation_path(conn, :index))
        |> halt()

      %User{confirmed_at: _} ->
        conn

      _ ->
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> maybe_store_return_to()
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: "/"
end
