defmodule Bookish.Router do
  use Bookish.Web, :router

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

  scope "/", Bookish do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/books", BooksController, :index
    get "/books/new", BooksController, :new
    get "/books/return", BooksController, :return
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bookish do
  #   pipe_through :api
  # end
end
