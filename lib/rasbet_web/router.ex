defmodule RasbetWeb.Router do
  use RasbetWeb, :router

  import RasbetWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {RasbetWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    # plug SetLocale, gettext: RasbetWeb.Gettext, default_locale: "pt"
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", RasbetWeb do
    pipe_through(:browser)

    live("/", GameLive.Index, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RasbetWeb do
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
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: RasbetWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", RasbetWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    # get "/users/register", UserRegistrationController, :new
    live("/users/register", UserLive.Registration, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", RasbetWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/users/settings", UserLive.Edit, :index)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)

    live("/user/wallet", WalletLive.Index, :index)
    live("/user/wallet/top-up_d", WalletLive.Index, :topup_d)
    live("/user/wallet/top-up_w", WalletLive.Index, :topup_w)
    live("/user/bets", WalletLive.Bets, :index)
    live("/user/bets/completed", WalletLive.Bets, :completed)
  end

  scope "/admin", RasbetWeb do
    pipe_through([:browser, :require_admin_user])

    live("/users", UserLive.List, :index)
    live("/users/:id/edit", UserLive.Edit, :edit)
    # post("/users/edit", UserLive.Edit, :update)
  end

  scope "/", RasbetWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)
  end
end
