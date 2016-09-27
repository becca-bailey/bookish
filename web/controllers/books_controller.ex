defmodule Bookish.BooksController do
  use Bookish.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def return(conn, _params) do
    render conn, "return.html"
  end
end
