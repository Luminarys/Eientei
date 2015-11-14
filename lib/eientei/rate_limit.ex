defmodule Eientei.RateLimit do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1]

  @interval Application.get_env(:eientei, :rate_interval)
  @max_requests Application.get_env(:eientei, :rate_access_max_requests)
  @max_data Application.get_env(:eientei, :rate_data_usage)

  def rate_limit(conn, options \\ []) do
    case check_amount_rate(conn) do
      {:ok, _count} -> conn
      _ -> render_error(conn)
    end
  end

  defp check_amount_rate(conn) do
    ExRated.check_rate(bucket_name(conn), @interval, @max_requests)
  end

  def check_data_rate(conn, 0) do
    case ExRated.check_rate(data_bucket_name(conn), @interval, @max_data) do
      {:ok, _count} -> :ok
      _ -> :rate_exceeded
    end
  end
  def check_data_rate(conn, size) do
    case ExRated.check_rate(data_bucket_name(conn), @interval, @max_data) do
      {:ok, count} ->
        check_data_rate(conn, size-1)
      _ -> :rate_exceeded
    end
  end

  # Bucket name should be a combination of ip address and request path
  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    ip   = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    "#{ip}:#{path}_amount"
  end

  defp data_bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    ip   = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    "#{ip}:#{path}_size"
  end

  defp render_error(conn) do
    conn
    |> put_status(429)
    |> json(%{"success" => false, "reason" => "Maximum upload rate exceeded!"})
    |> halt
  end
end
