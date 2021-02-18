use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :battleship, Battleship.Repo,
  username: "postgres",
  password: "pg-secret",
  database: "battleship_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :battleship, BattleshipWeb.Endpoint,
  http: [port: 4002],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :battleship, :sql_sandbox, true

config :wallaby, :chromedriver, path: "assets/node_modules/.bin/chromedriver"
config :wallaby, screenshot_on_failure: true
