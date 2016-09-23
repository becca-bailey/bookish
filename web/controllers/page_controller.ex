defmodule Bookish.PageController do
  use Bookish.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
