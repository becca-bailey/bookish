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
    get "/page/:number", PaginationController, :paginate
    get "/checked_out", BookController, :checked_out, as: :book
    get "/:book_id/return", ReturnController, :return, as: :return
    post "/:book_id/return", ReturnController, :process_return, as: :return
    put "/:book_id/return", ReturnController, :process_return, as: :return
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
    get "/book_records/:book_metadata_id/books/new", BookController, :new_with_existing_metadata, as: :book_metadata_book
    post "/book_records/:book_metadata_id/books/", BookController, :create_with_existing_metadata, as: :book_metadata_book
    resources "/book_records", BookMetadataController do
      resources "/books", BookController, only: [:new, :create]
    end

    resources "/books", BookController, except: [:index] do
      resources "/check_outs", CheckOutController, only: [:index, :new, :create]
    end

    resources "/tags", TagController, only: [:create, :delete, :show]
    resources "/locations", LocationController
    resources "/users", UserController
  end
end
