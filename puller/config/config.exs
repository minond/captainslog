# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :puller,
  ecto_repos: [Puller.Repo]

# Configures the endpoint
config :puller, PullerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KF4f5Co/fJAKUBQ5w3r5Du2CHl4StWToL+0Kj7e3NwO46IYbWFKY/ukkXX1l7b7G",
  render_errors: [view: PullerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Puller.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "zrdqdaAj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# From pow dependency
config :puller, :pow,
  user: Puller.Users.User,
  repo: Puller.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
