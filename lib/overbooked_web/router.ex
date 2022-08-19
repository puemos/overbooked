defmodule OverbookedWeb.Router do
  use OverbookedWeb, :router

  import OverbookedWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OverbookedWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OverbookedWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", OverbookedWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: OverbookedWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/", OverbookedWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/login", UserSessionController, :create
    get "/confirm/account/:token", UserConfirmationController, :confirm_account
  end

  scope "/", OverbookedWeb do
    pipe_through [:browser, :require_authenticated_user]
    delete "/logout", UserSessionController, :delete
    get "/confirm/email/:token", UserConfirmationController, :confirm_email
  end

  scope "/", OverbookedWeb do
    pipe_through [:browser]

    live_session :default,
      on_mount: [{OverbookedWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/login", LoginLive, :index
      live "/signup/:token", SignupLive, :index
      live "/signup/confirmation", UserResendConfirmationLive, :index
      live "/forgot-password", UserForgotPasswordLive, :index
      live "/reset-password/:token", UserResetPasswordLive, :index
    end

    live_session :authenticated,
      on_mount: [{OverbookedWeb.UserAuth, :ensure_authenticated}] do
      live "/", HomeLive, :index
      live "/settings", UserSettingsLive, :index
    end

    live_session :admin,
      on_mount: [{OverbookedWeb.UserAuth, :ensure_authenticated}] do
      live "/admin", AdminLive, :index
    end
  end
end
