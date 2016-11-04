defmodule Bookish.SearchController do
  use Bookish.Web, :controller

  alias Bookish.Resource
  alias Bookish.BookController
  alias Bookish.PaginationController, as: Pagination
  alias Bookish.Book
  
  def index_by_letter(conn, %{"letter" => letter}) do
    resources =
      Book
      |> Resource.get_by_letter(letter)
      |> BookController.load_from_query 
    render(conn, "index.html", books: resources, page_count: Pagination.number_of_pages, current_page: 1)
  end
end
