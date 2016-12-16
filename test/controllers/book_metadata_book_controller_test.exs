defmodule Bookish.BookMetadataBookControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  alias Bookish.BookMetadata

  @user %{id: "email", name: "user"}
  @invalid_attrs %{}

  test "renders a form to add a book with existing metadata", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_metadata_book_metadata_book_path(conn, :new, book_metadata))

    assert conn.status == 200
  end

  test "creates new book with existing metadata and redirects when data is valid", %{conn: conn} do
    attributes = %{location_id: 1, current_location: "somewhere"}
    book_metadata = Repo.insert! %BookMetadata{}
    conn =
      conn
      |> assign(:current_user, @user)
      |> post(book_metadata_book_metadata_book_path(conn, :create, book_metadata), book: attributes)

    assert Repo.get_by(Book, attributes)
    assert redirected_to(conn) == book_metadata_path(conn, :show, book_metadata)
  end

  test "does not create book and renders errors when data is invalid", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    conn =
      conn
      |> assign(:current_user, @user)
      |> post(book_metadata_book_metadata_book_path(conn, :create, book_metadata), book: @invalid_attrs)

    assert conn.status == 200
  end

  test "does not allow a non-logged in user to add a new book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    conn = get conn, book_metadata_book_metadata_book_path(conn, :new, book_metadata)

    assert redirected_to(conn) == "/"
  end

  test "renders form for editing a book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}

    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_metadata_book_metadata_book_path(conn, :edit, book_metadata, book))

    assert html_response(conn, 200) =~ "Edit book"
  end

  test "does not update book and renders errors when data is invalid", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}

    conn =
      conn
      |> assign(:current_user, @user)
      |> put(book_metadata_book_metadata_book_path(conn, :update, book_metadata, book), book: @invalid_attrs)

    assert html_response(conn, 200) =~ "Edit book"
  end
end
