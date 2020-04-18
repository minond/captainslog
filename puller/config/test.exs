use Mix.Config

# Configure your database
config :puller, Puller.Repo,
  username: "postgres",
  password: "postgres",
  database: "puller_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :puller, PullerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
