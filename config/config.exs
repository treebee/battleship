# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :battleship,
  ecto_repos: [Battleship.Repo]

# Configures the endpoint
config :battleship, BattleshipWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "d2PIWnp4GuizvRCqbRhkhjsQHwSgvi4XdTW9kKZ/qYjBKMVfUGw9ZGtGx/ZOqn5Y",
  render_errors: [view: BattleshipWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Battleship.PubSub,
  live_view: [signing_salt: "TtRImzdR"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
