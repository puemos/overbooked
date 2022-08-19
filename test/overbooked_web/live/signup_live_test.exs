defmodule OverbookedWeb.LiveTest do
  use OverbookedWeb.ConnCase, async: true

  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup do
    %{user: user_fixture()}
  end

  describe "visit signup page" do
    setup %{user: user} do
      token = registration_token_fixture(user.email)

      %{token: token.token_string}
    end

    test "renders signup page", %{conn: conn, token: token} do
      conn = get(conn, Routes.signup_path(conn, :index, token))
      {:ok, _view, html} = live(conn)

      assert html =~ "Sign up"
    end

    test "redirects if already logged in", %{conn: conn, token: token} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.signup_path(conn, :index, token))
      assert redirected_to(conn) == "/"
    end
  end

  describe "sign up" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()
      token = registration_token_fixture(email).token_string
      conn = get(conn, Routes.signup_path(conn, :index, token))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form("#signup-form",
          user: %{
            email: email,
            name: "john",
            password: valid_user_password(),
            password_confirmation: valid_user_password()
          }
        )
        |> render_submit()

      assert_redirect(view, Routes.user_resend_confirmation_path(conn, :index))

      assert {:error,
              {:redirect,
               %{
                 flash: _,
                 to: "/signup/confirmation"
               }}} = response
    end

    test "render errors for invalid data", %{conn: conn} do
      email = unique_user_email()
      token = registration_token_fixture(email).token_string
      conn = get(conn, Routes.signup_path(conn, :index, token))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form("#signup-form",
          user: %{
            email: "with spaces",
            password: "too short",
            password_confirmation: "do not much"
          }
        )
        |> render_submit()

      assert response =~ "Sign up"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end

    test "render errors for invalid token", %{conn: conn} do
      email = unique_user_email()
      token = registration_token_fixture(email <> "a").token_string
      conn = get(conn, Routes.signup_path(conn, :index, token))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form("#signup-form",
          user: %{
            email: email,
            password: valid_user_password(),
            password_confirmation: valid_user_password()
          }
        )
        |> render_submit()

      assert response =~ "Sign up"
    end
  end
end
