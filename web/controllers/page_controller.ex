defmodule Eientei.PageController do
  use Eientei.Web, :controller

  @service_domain Application.get_env(:eientei, :service_domain)

  @use_fallback Application.get_env(:eientei, :fallback_service)
  @fallback_url Application.get_env(:eientei, :fallback_service_url)
  @max_cache_size Application.get_env(:eientei, :max_cache_size)

  def index(conn, _params) do
    render conn, "index.html"
  end

  def faq(conn, _params) do
   render conn, "faq.html"
  end

  def info(conn, _params) do
    render conn, "info.html"
  end

  def contact(conn, _params) do
    render conn, "contact.html"
  end

  def tools(conn, _params) do
    render conn, "tools.html"
  end

  def file(conn, %{"file" => filename}) do
    require Pipe
    resp =Pipe.pipe_matching val, {:ok, val},
    {:ok, filename}
    |> check_cache
    |> check_file_loc
    |> check_db
    |> check_fallback

    send_file_response(resp, conn, filename)
  end

  defp send_file_response(:redirect, conn, filename) do
    redirect conn, external: "#{@fallback_url}/#{filename}"
  end
  defp send_file_response({:cached, data}, conn, filename) do
    conn
    |> put_resp_content_type(Plug.MIME.path(filename))
    |> send_resp(200, data)
  end
  defp send_file_response({:file, filename, path}, conn, filename) do
    Task.start(fn -> cache_file(filename, path) end)
    conn
    |> put_resp_content_type(Plug.MIME.path(path))
    |> send_file(200, path)
  end
  defp send_file_response(:no_file, conn, _file) do
    conn
    |> put_status(404)
    |> put_flash(:error, "The file you tried to view does not exist!")
    |> render("index.html")
  end

  defp cache_file(filename, path) do
    ets = ConCache.ets(:file_cache)
    size = :ets.info(ets) |> Keyword.get(:size)
    if size >= @max_cache_size do
        :random.seed(:os.timestamp)
        {item, _} = Enum.random(ets |> :ets.tab2list)
        ConCache.delete(:file_cache, item)
    end
    ConCache.put(:file_cache, filename, File.read! path)
  end

  defp check_cache(filename) do
    case ConCache.get(:file_cache, filename) do
      nil -> {:ok, filename}
      val -> {:cached, val}
    end
  end

  defp check_file_loc(filename) do
    case File.exists?("files/" <> filename) do
       true -> {:file, filename, "files/" <> filename}
       false -> {:ok, filename}
    end
  end

  defp check_db(filename) do
    case Eientei.Repo.get_by(Eientei.Upload, name: filename) do
      nil -> {:ok, filename}
      %{location: path} -> {:file, filename, path}
    end
  end

  defp check_fallback(filename) when @use_fallback do
    {:ok, fallback_resp} = HTTPoison.get("#{@fallback_url}/#{filename}")
      case fallback_resp do
        %{status_code: 200} -> :redirect
        %{status_code: 301} -> :redirect
        %{status_code: 302} -> :redirect
        %{status_code: _status} ->  :no_file
      end
  end
  defp check_fallback(_file) do
    :no_file
  end
end
