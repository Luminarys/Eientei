defmodule Eientei.Router do
  use Eientei.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Eientei do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/faq", PageController, :faq
    get "/contact", PageController, :contact
    get "/tools", PageController, :tools
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
