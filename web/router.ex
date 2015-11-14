defmodule Eientei.Router do
  use Eientei.Web, :router
  import Eientei.RateLimit

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
    plug :rate_limit
    plug :accepts, ["json"]
  end

  scope "/", Eientei do
    pipe_through [:browser, :csrf]

    get "/", PageController, :index
    get "/faq", PageController, :faq
    get "/contact", PageController, :contact
    get "/tools", PageController, :tools
  end

  @use_csrf_protection Application.get_env(:eientei, :use_csrf_protection)
  scope "/", Eientei do
    if @use_csrf_protection do
      pipe_through [:browser, :csrf]
    else
      pipe_through [:browser]
    end

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
