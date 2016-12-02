defmodule Bookish.BookMetadataControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book

  @book_params %{"title" => "A book", "author_firstname" => "first", "author_lastname" => "last", "year" => 2016, "edition" => "first"}
  @user %{id: "email", name: "user"}

  test "Creating a book creates associated metadata", %{conn: conn} do
    conn
    |> assign(:current_user, @user)
    |> post(book_path(conn, :create), book: @book_params)

    book =
      Repo.all(Book)
      |> List.first
      |> Repo.preload(:book_metadata)

     data = book.book_metadata

     assert data.title == @book_params["title"]
     assert data.author_firstname == @book_params["author_firstname"]
     assert data.author_lastname == @book_params["author_lastname"]
     assert data.year == @book_params["year"]
  end
end
