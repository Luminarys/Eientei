defmodule Eientei.PageController do
  use Eientei.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def faq(conn, _params) do
    render conn, "faq.html"
  end

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
            conn
            |> put_flash(:error, "The file you tried to view does not exist!")
            |> render "index.html"
          %{location: location} ->
            conn
            |> put_resp_content_type(Plug.MIME.path(location))
            |> send_file(200, location)
        end
    end
  end
end
