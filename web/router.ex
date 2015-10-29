defmodule Eientei.Router do
  use Eientei.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Eientei do
    pipe_through [:browser, :csrf]

    get "/", PageController, :index
    get "/faq", PageController, :faq
    get "/contact", PageController, :contact
    get "/tools", PageController, :tools
  end

  scope "/", Eientei do
    pipe_through [:browser]

    # Let's not break compat quite yet
    get "/:file", PageController, :file
    get "/f/:file", PageController, :file
    get "/:file/:rn", PageController, :file
  end

  scope "/api/", Eientei do
    pipe_through :api
    post "upload", UploadController, :upload
  end
end
