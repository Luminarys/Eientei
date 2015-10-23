use Mix.Config

# SECRET KEY CONFIGURATION
config :eientei, Eientei.Endpoint,
  # Generate this by running mix phoenix.gen.secret
  secret_key_base: "Insert generated secret key here!"

# AUTO ARCHIVE CONFIGURATION
# Setup auto archiving settings here.
config :eientei,
  # Set this to true if you do want autoarchiving
  use_ia_archive: false,
  ia_access: "YOUR ACCESS KEY",
  ia_secret: "YOUR SECRET KEY",
  ia_service_name: "YOUR SERVICE NAME",
  ia_sponsor: "YOUR REAL NAME OR HANDLE"

# FALLBACK SERVICE CONFIGURATION
# If you are migrating from an old service, you can have it check
# if the queried file is there, so as to not confuse users.
# Set this to true to enable it.
config :eientei,
  fallback_service: false,
  # Set these two options to create an alert on the front page telling users how to find your fallback/old service
  fallback_service_alert: false,
  # Don't put a http(s) on this, just domain.tld
  fallback_service_home_page: "previous-pomf-homepage-url.tld",
  # Don't put a trailing / on this
  fallback_service_url: "https://previous-pomf-file-location.tld"

# GENERAL CONFIGURATION
# Note that it is assumed that you have an abuse@ email
config :eientei,
  service_name: "Service Name",
  service_url: "service.tld",
  contact_email: "mycontactaddress@email.com",
  # Max UL size in MegaBytes
  max_upload_size: 32

# DATABSE CONFIGURATION
config :eientei, Eientei.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "eientei_#{Mix.env}",
  pool_size: 20
