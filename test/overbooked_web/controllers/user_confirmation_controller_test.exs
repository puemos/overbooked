defmodule OverbookedWeb.UserConfirmationControllerTest do
  use OverbookedWeb.ConnCase

  alias Overbooked.Accounts
  alias Overbooked.Repo
  import Overbooked.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "GET /confirm/email/:token" do
    setup :register_and_log_in_user

    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.login_path(conn, :index)
    end
  end

  describe "GET /confirm/account/:token" do
    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_account, token))
      assert redirected_to(conn) == "/login"
      assert get_flash(conn, :info) =~ "User confirmed successfully"
      assert Accounts.get_user!(user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) == []

      # When not logged in
      conn =
        build_conn()
        |> get(Routes.user_confirmation_path(conn, :confirm_account, token))

      assert redirected_to(conn) == "/signup/confirmation"
      assert get_flash(conn, :error) =~ "User confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_user(user)
        |> get(Routes.user_confirmation_path(conn, :confirm_account, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm_account, "oops"))
      assert redirected_to(conn) == "/signup/confirmation"
      assert get_flash(conn, :error) =~ "User confirmation link is invalid or it has expired"
      refute Accounts.get_user!(user.id).confirmed_at
    end
  end
end
