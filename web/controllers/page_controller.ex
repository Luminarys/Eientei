defmodule Eientei.PageController do
  use Eientei.Web, :controller

  @service_domain Application.get_env(:eientei, :service_domain)

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

  @use_fallback Application.get_env(:eientei, :fallback_service)
  @fallback_url Application.get_env(:eientei, :fallback_service_url)

  def file(conn, %{"file" => file}) do
    require Pipe

    resp = Pipe.pipe_matching val, {:ok, val},
    {:ok, file}
    |> check_cache
    |> check_file_loc
    |> check_db
    |> check_fallback

    case resp do
      :redirect ->
        redirect conn, external: "#{@fallback_url}/#{file}"
      {:cached, val} ->
        conn
        |> put_resp_content_type(Plug.MIME.path(file))
        |> send_resp(200, val)
      {:file, loc} ->
        Task.start(fn -> ConCache.put(:file_cache, file, File.read! loc) end)
         conn
         |> put_resp_content_type(Plug.MIME.path(file))
         |> send_file(200, loc)
      :no_file ->
        conn
        |> put_status(404)
        |> put_flash(:error, "The file you tried to view does not exist!")
        |> render "index.html"
    end
  end

  defp check_cache(file) do
    case ConCache.get(:file_cache, file) do
      nil -> {:ok, file}
      val -> {:cached, val}
    end
  end

  defp check_file_loc(file) do
    case File.exists?("files/" <> file) do
       true -> {:file, "files/" <> file}
       false -> {:ok, file}
    end
  end

  defp check_db(file) do
    case Eientei.Repo.get_by(Eientei.Upload, name: Path.basename(file, Path.extname(file))) do
      nil -> {:ok, file}
      %{location: location} -> {:file, location}
    end
  end

  defp check_fallback(file) when @use_fallback do
    {:ok, fallback_resp} = HTTPoison.get("#{@fallback_url}/#{file}")
      case fallback_resp do
        %{status_code: 200} -> :redirect
        %{status_code: 301} -> :redirect
        %{status_code: 302} -> :redirect
        %{status_code: status} ->  :no_file
      end
  end
  defp check_fallback(file) do
    :no_file
  end
end
