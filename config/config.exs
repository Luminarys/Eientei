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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# PLEASE OVERRIDE THESE IN THE prod.secret.exs or dev.secret.exs FILE!
config :eientei,
  # SET THIS TO FALSE IF YOU DO NOT WANT AUTO-ARCHIVING
  use_ia_archive: true,
  ia_access: "YOUR ACCESS KEY",
  ia_secret: "YOUR SECRET KEY",
  ia_service_name: "YOUR SERVICE NAME",
  ia_sponsor: "YOUR REAL NAME OR HANDLE"

# Various general information bits
# Note that it is assumed that you have an abuse@ email
config :eientei,
  service_name: "Fuwa",
  service_url: "fuwa.se",
  contact_email: "luminarys@fuwa.se",
  # Max UL size in MegaBytes
  max_upload_size: 32

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
