defmodule Eientei.PageController do
  use Eientei.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def faq(conn, _params) do
    render conn, "faq.html"
  end

  @use_fallback Application.get_env(:eientei, :fallback_service)
  @fallback_url Application.get_env(:eientei, :fallback_service_url)

  def file(conn, %{"file" => file}) do
    case File.exists?("files/" <> file) do
      true ->
        conn
        |> put_resp_content_type(Plug.MIME.path(file))
        |> send_file(200, "files/" <> file)
      false ->
        # Query DB to see if it's a copy file
        case Eientei.Repo.get_by(Eientei.Upload, name: file) do
          nil ->
            # Query previous page
            case @use_fallback do
              true ->
                {:ok, fallback_resp} = HTTPoison.get("#{@fallback_url}/#{file}")
                  case fallback_resp do
                    %{status_code: 200} -> redirect conn, external: "#{@fallback_url}/#{file}"
                    %{status_code: 301} -> redirect conn, external: "#{@fallback_url}/#{file}"
                    %{status_code: 302} -> redirect conn, external: "#{@fallback_url}/#{file}"
                    %{status_code: status} -> 
                      conn
                      |> put_status(404)
                      |> put_flash(:error, "The file you tried to view does not exist!")
                      |> render "index.html"
                  end
              false ->
                conn
                |> put_status(404)
                |> put_flash(:error, "The file you tried to view does not exist!")
                |> render "index.html"
            end
          %{location: location} ->
            conn
            |> put_resp_content_type(Plug.MIME.path(location))
            |> send_file(200, location)
        end
    end
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
end
