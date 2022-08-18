defmodule OverbookedWeb.UserForgotPasswordLiveTest do
  use OverbookedWeb.ConnCase, async: true

  alias Overbooked.Accounts
  alias Overbooked.Repo
  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup do
    %{user: user_fixture()}
  end

  describe "request for password reset" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_forgot_password_path(conn, :index))
      {:ok, view, _html} = live(conn)

      view
      |> form("#forgot-password-form", user: %{"email" => user.email})
      |> render_submit()

      flash = assert_redirect(view, "/login")
      assert flash["info"] =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn = get(conn, Routes.user_forgot_password_path(conn, :index))
      {:ok, view, _html} = live(conn)

      view
      |> form("#forgot-password-form", user: %{"email" => "unknown@example.com"})
      |> render_submit()

      flash = assert_redirect(view, "/login")
      assert flash["info"] =~ "If your email is in our system"

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
