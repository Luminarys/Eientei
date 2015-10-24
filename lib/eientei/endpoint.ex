defmodule Eientei.Endpoint do
  use Phoenix.Endpoint, otp_app: :eientei

  socket "/socket", Eientei.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :eientei, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  @max_upload_size Application.get_env(:eientei, :max_upload_size)

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: @max_upload_size * 1000 * 1000

  plug Plug.MethodOverride
  plug Plug.Head


  plug Plug.Session,
    store: :cookie,
    key: "_eientei_key",
    signing_salt: "6ot8uYMj"

  plug Eientei.Router
end
