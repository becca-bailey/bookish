defmodule Bookish.PaginationController do
  use Bookish.Web, :controller

  alias Bookish.Resource
  alias Bookish.BookController
  alias Bookish.BookMetadata

  @entries_per_page 10
  
  def paginate(conn, params) do
    case params do
      %{"number" => "1"} ->
        redirect(conn, to: book_path(conn, :index))
      %{"number" => _ } ->
        show_pages(conn, params)
    end
  end
  
  def show_pages(conn, %{"number" => number}) do
    n = String.to_integer(number)
    resources = Repo.all(BookMetadata) |> Repo.preload(:tags) 
    # resources = 
    #   Book
    #   #|> Resource.sorted_by_title
    #   |> Resource.paginate(n, @entries_per_page)
    #   |> BookController.load_from_query
    render(conn, "index.html", books: resources, page_count: 1, current_page: n)
  end

  def number_of_pages do
    count = 
      Book
      |> Resource.count
      |> Repo.all
      |> List.first
    Float.ceil(count / @entries_per_page)
    |> Kernel.trunc
  end
end
