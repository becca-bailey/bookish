defmodule Bookish.Router do
  use Bookish.Web, :router
  require Ueberauth

  @book_metadata "/book_records"
  @books "/books"

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

  scope @books, Bookish do
    pipe_through :browser
    get "/checked_out", BookController, :checked_out, as: :book
    get "/:book_id/return", ReturnController, :return, as: :return
    post "/:book_id/return", ReturnController, :process_return, as: :return
    put "/:book_id/return", ReturnController, :process_return, as: :return
  end

  scope @book_metadata, Bookish do
    pipe_through :browser
    get "/page/:number", BookMetadataPaginationController, :index, as: :book_metadata_pagination
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
    resources @book_metadata, BookMetadataController do
      resources @books, BookMetadataBookController, only: [:new, :create, :edit, :update]
      resources "/locations", BookMetadataLocationController, only: [:show]
    end

    resources @books, BookController, except: [:index, :show] do
      resources "/check_outs", CheckOutController, only: [:index, :new, :create]
    end

    resources "/tags", TagController, only: [:create, :delete, :show]
    resources "/locations", LocationController
    resources "/users", UserController
  end
end
