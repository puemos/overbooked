defmodule OverbookedWeb.LoginLiveTest do
  use OverbookedWeb.ConnCase, async: true

  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup do
    %{user: user_fixture()}
  end

  describe "view login page" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :index))
      {:ok, _view, html} = live(conn)

      assert html =~ "Log in</h1>"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.login_path(conn, :index))
      assert redirected_to(conn) == "/"
    end
  end
end
