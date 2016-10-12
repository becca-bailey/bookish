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

  scope "/books", Bookish do
    pipe_through :browser

    get "/checked_out", Circulation, :checked_out, as: :circulation
    get "/:id/return", Circulation, :return, as: :circulation
    post "/:id/return", Circulation, :process_return, as: :circulation
  end

  scope "/", Bookish do
    pipe_through :browser 

    get "/", PageController, :index

    resources "/books", BookController do
      resources "/check_outs", CheckOutController
    end
  end
end
