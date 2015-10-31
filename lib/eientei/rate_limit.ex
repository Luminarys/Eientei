defmodule Eientei.RateLimit do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1]

  @interval Application.get_env(:eientei, :rate_access_interval)
  @max_requests Application.get_env(:eientei, :rate_access_max_requests)

  def rate_limit(conn, options \\ []) do
    case check_rate(conn, options) do
      {:ok, _count}   -> conn
      {:fail, _count} -> render_error(conn)
    end
  end

  defp check_rate(conn, _options) do
    interval_milliseconds = @interval * 1000
    max_requests = @max_requests
    ExRated.check_rate(bucket_name(conn), interval_milliseconds, max_requests)
  end

  # Bucket name should be a combination of ip address and request path
  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    ip   = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    "#{ip}:#{path}"
  end

  defp render_error(conn) do
    conn
    |> put_status(429)
    |> json(%{"success" => false, "reason" => "Maximum upload rate exceeded!"})
    |> halt
  end
end
