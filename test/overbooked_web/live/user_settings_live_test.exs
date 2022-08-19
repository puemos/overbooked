defmodule OverbookedWeb.UserSettingsLiveTest do
  use OverbookedWeb.ConnCase, async: true

  alias Overbooked.Accounts
  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "visit settings page" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, _view, html} = live(conn)

      assert html =~ "Settings</h1>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :index))
      assert redirected_to(conn) == Routes.login_path(conn, :index)
    end
  end

  describe "change profile form" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, view, html} = live(conn)
      assert html =~ user.name

      response =
        view
        |> form(
          "#change-profile-form",
          %{
            "user" => %{
              "name" => "a name"
            }
          }
        )
        |> render_submit()

      assert {:error, {:live_redirect, %{flash: _, kind: :push, to: "/settings"}}} = response

      {:ok, _view, html} = live(conn)
      assert html =~ "a name"
    end
  end

  describe "change password form" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form(
          "#change-password-form",
          %{
            "user" => %{
              "password" => "new valid password",
              "password_confirmation" => "new valid password"
            },
            "current_password" => "hello world!"
          }
        )
        |> render_submit()

      assert response =~ "Password updated successfully."

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")

      # Try to login with the new password
      conn = build_conn()

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "new valid password"}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ user.email
    end

    test "does not update password on invalid data", %{conn: conn} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form(
          "#change-password-form",
          %{
            "user" => %{
              "password" => "too short",
              "password_confirmation" => "does not match"
            },
            "current_password" => "invalid"
          }
        )
        |> render_submit()

      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"
    end
  end

  describe "change email form" do
    @tag :capture_log
    test "updates the user email", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, view, _html} = live(conn)

      new_email = unique_user_email()

      response =
        view
        |> form(
          "#change-email-form",
          %{
            "user" => %{
              "email" => new_email
            },
            "current_password" => "hello world!"
          }
        )
        |> render_submit()

      assert response =~ "A link to confirm your email change has been sent to the new address."
      assert Accounts.get_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn = get(conn, Routes.user_settings_path(conn, :index))
      {:ok, view, _html} = live(conn)

      response =
        view
        |> form(
          "#change-email-form",
          %{
            "user" => %{
              "email" => "with spaces"
            },
            "current_password" => "invalid"
          }
        )
        |> render_submit()

      assert response =~ "Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end
end
