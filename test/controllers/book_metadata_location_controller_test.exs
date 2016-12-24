defmodule Bookish.BookMetadataLocationControllerTest do
  use Bookish.ConnCase

  alias Bookish.Location
  alias Bookish.BookMetadata
  alias Bookish.Book

  test "the location show route shows a list of books with that location and metadata",
  %{conn: conn} do
    location = Repo.insert! %Location{name: "Chicago"}
    metadata = Repo.insert! %BookMetadata{title: "Book"}
    Repo.insert!(%Book{book_metadata: metadata, location: location, current_location: "10th floor"})

    conn = get conn, book_metadata_book_metadata_location_path(conn, :show, metadata, location)

    assert html_response(conn, 200) =~ "Copies of Book in Chicago"
    assert html_response(conn, 200) =~ "10th floor"
  end

  test "if a book is checked out, the div has the class 'checked-out", %{conn: conn} do
    location = Repo.insert! %Location{name: "Chicago"}
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata, location: location}
    Ecto.build_assoc(book, :check_outs, borrower_name: "Becca")
    |> Repo.insert!

    conn = get conn, book_metadata_book_metadata_location_path(conn, :show, book_metadata, location)

    assert html_response(conn, 200) =~ "checked-out"
  end

  test "if a book is not checked out, the div has the class 'available'", %{conn: conn} do
    location = Repo.insert! %Location{name: "Chicago"}
    book_metadata = Repo.insert! %BookMetadata{}
    Repo.insert! %Book{book_metadata: book_metadata, location: location}

    conn = get conn, book_metadata_book_metadata_location_path(conn, :show, book_metadata, location)

    assert html_response(conn, 200) =~ "available"
  end
end
