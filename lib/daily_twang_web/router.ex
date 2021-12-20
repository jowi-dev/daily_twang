defmodule DailyTwangWeb.Router do
  use DailyTwangWeb, :router

  import DailyTwangWeb.AccountAuth

  def default_pwa_assigns(conn, _opts) do
    conn
    |> assign(:meta_attrs, [])
    |> assign(:manifest, nil)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DailyTwangWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug :default_pwa_assigns
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DailyTwangWeb do
    pipe_through :browser

    live "/", PostLive.Index, :index

    live "/posts", PostLive.Index, :index
    # live "/posts/:id", PostLive.Index, :show
  end

  scope "/pwa", DailyTwangWeb.Pwa, as: :pwa do
    pipe_through :browser
    resources "/posts", PostController, only: [:index]
  end

  # Other scopes may use custom stacks.
  scope "/api", DailyTwangWeb do
    pipe_through :api

    resources "/posts", PostController, except: [:new, :edit]
  end

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
      live_dashboard "/dashboard", metrics: DailyTwangWeb.Telemetry
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

  scope "/", DailyTwangWeb do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    get "/accounts/register", AccountRegistrationController, :new
    post "/accounts/register", AccountRegistrationController, :create
    get "/accounts/log_in", AccountSessionController, :new
    post "/accounts/log_in", AccountSessionController, :create
    get "/accounts/reset_password", AccountResetPasswordController, :new
    post "/accounts/reset_password", AccountResetPasswordController, :create
    get "/accounts/reset_password/:token", AccountResetPasswordController, :edit
    put "/accounts/reset_password/:token", AccountResetPasswordController, :update
  end

  scope "/", DailyTwangWeb do
    pipe_through [:browser, :require_authenticated_account]

    get "/accounts/settings", AccountSettingsController, :edit
    put "/accounts/settings", AccountSettingsController, :update
    get "/accounts/settings/confirm_email/:token", AccountSettingsController, :confirm_email
  end

  scope "/", DailyTwangWeb do
    pipe_through [:browser]

    delete "/accounts/log_out", AccountSessionController, :delete
    get "/accounts/confirm", AccountConfirmationController, :new
    post "/accounts/confirm", AccountConfirmationController, :create
    get "/accounts/confirm/:token", AccountConfirmationController, :edit
    post "/accounts/confirm/:token", AccountConfirmationController, :update
  end
end
