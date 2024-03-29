# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :rasbet,
  ecto_repos: [Rasbet.Repo],
  endpoint: "http://ucras.di.uminho.pt/v1",
  # endpoint: "https://rasapi.pta2002.com/v1",
  sports: %{
    football: "Futebol",
    tennis: "Ténis"
  }

# Configures the endpoint
config :rasbet, RasbetWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: RasbetWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Rasbet.PubSub,
  live_view: [signing_salt: "dzww0dxG"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :rasbet, Rasbet.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure tailwind
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :money,
  default_currency: :EUR

config :rasbet, RasbetWeb.Gettext, default_locale: "pt", locales: ~w(en pt)

config :rasbet, Rasbet.Scheduler,
  debug_logging: false,
  jobs: [
    fetch_games: [
      schedule: {:extended, "*/10"},
      task: {Rasbet.APIs, :update, []}
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
