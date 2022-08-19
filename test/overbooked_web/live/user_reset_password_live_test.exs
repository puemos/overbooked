defmodule OverbookedWeb.UserResetPasswordLiveTest do
  use OverbookedWeb.ConnCase, async: true

  alias Overbooked.Accounts
  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup do
    %{user: user_fixture()}
  end

  describe "visit reset password page" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.user_reset_password_path(conn, :index, token))
      {:ok, _view, html} = live(conn)

      assert html =~ "Reset password"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :index, "oops"))

      assert {:error,
              {:redirect,
               %{
                 flash: %{"error" => "Reset password link is invalid or it has expired."},
                 to: "/login"
               }}} = live(conn)
    end
  end

  describe "reseting the password" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, user: user, token: token} do
      conn = get(conn, Routes.user_reset_password_path(conn, :index, token))
      {:ok, view, _html} = live(conn)

      view
      |> form("#reset-password-form",
        user: %{
          "password" => "new valid password",
          "password_confirmation" => "new valid password"
        }
      )
      |> render_submit()

      flash = assert_redirect(view, Routes.login_path(conn, :index))
      refute get_session(conn, :user_token)

      assert flash["info"] =~ "Password reset successfully"

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn = get(conn, Routes.user_reset_password_path(conn, :index, token))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form("#reset-password-form",
          user: %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        )
        |> render_submit()

      assert response =~ "Reset password"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end
  end
end
