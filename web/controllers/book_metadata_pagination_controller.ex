defmodule Bookish.BookMetadataPaginationController do
  use Bookish.Web, :controller

  alias Bookish.Repository

  @entries_per_page 10

  def index(conn, params) do
    case params do
      %{"number" => "1"} ->
        redirect(conn, to: book_metadata_path(conn, :index))
      %{"number" => n} ->
        n = String.to_integer(n)
        metadata = Repository.get_metadata(n, @entries_per_page)
        render(conn, "index.html", books: metadata,
                                   page_count: Repository.total_number_of_pages(@entries_per_page),
                                   current_page: n)
    end
  end
end
