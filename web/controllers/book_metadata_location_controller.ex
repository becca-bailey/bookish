defmodule Bookish.BookMetadataLocationController do
  use Bookish.Web, :controller

  alias Bookish.Location
  alias Bookish.Book
  alias Bookish.BookMetadata
  
  def show(conn, %{"book_metadata_id" => book_metadata_id, "id" => id}) do
    book_metadata = Repo.get!(BookMetadata, book_metadata_id)
    location = Repo.get!(Location, id) |> Repo.preload(:books)
    books = 
      Book
      |> Book.get_books_for_location_with_metadata(location, book_metadata)
      |> Repo.all
      |> Repo.preload(:location)
    render(conn, "show.html", location: location, books: books, book_metadata: book_metadata)
  end
end
