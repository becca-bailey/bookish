defmodule Bookish.Router do
  use Bookish.Web, :router
  require Ueberauth

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

  scope "/books", Bookish do
    pipe_through :browser
    get "/starting-with/:letter", BookController, :index_by_letter, as: :book
    get "/page/:number", BookController, :paginate, as: :book
    get "/checked_out", Circulation, :checked_out, as: :circulation
    get "/:id/return", Circulation, :return, as: :circulation
    post "/:id/return", Circulation, :process_return, as: :circulation
    put "/:id/return", Circulation, :process_return, as: :circulation
    
    resources "/tags", TagController, only: [:show], as: :books_tag
    resources "/locations", LocationController, only: [:show], as: :books_location
  end

  scope "/auth", Bookish do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/", Bookish do
    pipe_through :browser 

    get "/", PageController, :index

    resources "/books", BookController, except: [:show] do
      resources "/check_outs", CheckOutController, only: [:index, :new, :create]
    end

    resources "/tags", TagController, only: [:create, :delete]
    resources "/locations", LocationController
    resources "/users", UserController
  end
end
