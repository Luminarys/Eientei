# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :eientei, Eientei.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "Nixw4hRwgf7ZC3i+k6FmUGgdlgr10+K6FRRIZSY7Ig83aeUWX1kGh4ZIUkJBrCjG",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Eientei.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Set port based on env_var, otherwise use default of 21111
case System.get_env("PORT") do
  nil ->
    config :eientei, Eientei.Endpoint,
      http: [port: 21111]
  port_num ->
    config :eientei, Eientei.Endpoint,
      http: [port: port_num]
end

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Link to git repo
config :eientei,
  git_repo_url: "https://github.com/luminarys/eientei"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
