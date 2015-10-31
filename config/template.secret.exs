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
  # Don't put a trailing / on this - e.g. for the original Pomf, this would be  a.pomf.se
  fallback_service_url: "https://previous-file-hosting-domain.tld"
  # Set these two options to create an alert on the front page telling users how to find your fallback/old service
  fallback_service_alert: false,
  # Don't put a http(s) on this, just domain.tld
  fallback_service_home_page: "previous-homepage-url.tld",

# GENERAL CONFIGURATION
# Note that it is assumed that you have an abuse@ email
config :eientei,
  service_name: "Service Name",
  service_domain: "service.tld",
  service_url: "https://service.tld",
  # This should be used to specify a response url. Make sure to set http/https properly
  # If you want to serve files at f.service.tld set that here. Please don't add a trailing /
  contact_email: "mycontactaddress@email.com",
  # Max UL size in MegaBytes
  max_upload_size: 32,
  # Maximum number of cache entries.
  # For safety purposes do not let
  # max_cache_size * max_upload_size/1000
  # exceed your RAM amount(in gigabytes))
  max_cache_size: 100

# RATE LIMITING
# This should be used to block spam.
config :eientei,
  # Interval in seconds
  rate_access_interval: 60,
  # NUmber of files which can be uploaded during the interval
  rate_access_usage: 20

# DATABSE CONFIGURATION
config :eientei, Eientei.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "eientei_#{Mix.env}",
  pool_size: 20
