defmodule Bookish.BookMetadataLocationController do
  use Bookish.Web, :controller

  alias Bookish.Repository

  def show(conn, %{"book_metadata_id" => book_metadata_id, "id" => id}) do
    book_metadata = Repository.get_metadata(book_metadata_id)
    location = Repository.get_location(id)
    render(conn, "show.html", location: location,
                              books: Repository.get_books_for_location_with_metadata(location, book_metadata),
                              book_metadata: book_metadata)
  end
end
