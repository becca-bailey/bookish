defmodule Bookish.BookControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  alias Bookish.BookMetadata

  @book_attrs %{title: "Title", author_firstname: "First", author_lastname: "Last", year: 2016, current_location: "some content", location_id: 1}

  @valid_attrs %{current_location: "some content", location_id: 1}
  @invalid_attrs %{}
  @user %{id: "email", name: "user"}
  
  test "creates new book and redirects when data is valid", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, @user)
      |> post(book_path(conn, :create), book: @book_attrs)

    book = Repo.get_by(Book, @valid_attrs) |> Repo.preload(:book_metadata)

    assert book
    assert redirected_to(conn) == book_metadata_path(conn, :show, book.book_metadata)
  end

  test "renders form to add a new book", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_path(conn, :new))

    assert html_response(conn, 200) =~ "New book"
  end

  test "does not allow a non-logged in user to add a new book", %{conn: conn} do
    conn = get conn, book_path(conn, :new)
  
    assert redirected_to(conn) == "/"
  end
  
  test "does not create book and renders errors when data is invalid", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, @user)
      |> post(book_path(conn, :create), book: @invalid_attrs)
  
    assert html_response(conn, 200) =~ "New book"
  end
  
  test "does not allow a non-logged in user to create a book", %{conn: conn} do
    conn = post conn, book_path(conn, :create), book: @valid_attrs
 
    assert redirected_to(conn) == "/"
  end
 
  test "renders form for editing a book", %{conn: conn} do
    book = Repo.insert! %Book{}
 
    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_path(conn, :edit, book))
 
    assert html_response(conn, 200) =~ "Edit book"
  end
  
  test "does not allow a non-logged in user to edit a book", %{conn: conn} do
    book = Repo.insert! %Book{}

    conn = get conn, book_path(conn, :edit, book)

    assert redirected_to(conn) == "/"
  end

  test "updates a book and redirects when data is valid", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}
    params = %{location_id: 1, current_location: "location"}

    conn =
      conn
      |> assign(:current_user, @user)
      |> put(book_path(conn, :update, book), book: params)

    assert redirected_to(conn) == book_metadata_path(conn, :show, book_metadata)
    assert Repo.get_by(Book, params)
  end

  test "does not update book and renders errors when data is invalid", %{conn: conn} do
    book = Repo.insert! %Book{}
  
    conn =
      conn
      |> assign(:current_user, @user)
      |> put(book_path(conn, :update, book), book: @invalid_attrs)
  
    assert html_response(conn, 200) =~ "Edit book"
  end
 
  test "does not allow a non-logged in user to update a book", %{conn: conn} do
    book = Repo.insert! %Book{}
 
    conn = put conn, book_path(conn, :delete, book)
 
    assert redirected_to(conn) == "/"
  end
  
  test "deletes a book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}
 
    conn =
      conn
      |> assign(:current_user, @user)
      |> delete(book_path(conn, :delete, book))
 
    assert redirected_to(conn) == book_metadata_path(conn, :show, book_metadata)
    refute Repo.get(Book, book.id)
  end
 
  test "does not allow a non-logged in user to delete a book", %{conn: conn} do
    book = Repo.insert! %Book{}
 
    conn = delete conn, book_path(conn, :delete, book)
 
    assert redirected_to(conn) == "/"
    assert Repo.get(Book, book.id)
  end

  test "renders checked_out page", %{conn: conn} do
    conn = get conn, "/books/checked_out"
    assert conn.status == 200
  end

  test "checked_out renders only books that are checked out", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{title: "This book is checked out"}
    checked_out_book = Repo.insert! %Book{book_metadata: book_metadata}
    book_metadata2 = Repo.insert! %BookMetadata{title: "This book is not checked out"}
    Repo.insert! %Book{book_metadata: book_metadata2}
 
    check_out =
      Ecto.build_assoc(checked_out_book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)
 
    conn = get conn, book_path(conn, :checked_out)
    assert html_response(conn, 200) =~ "This book is checked out"
    refute html_response(conn, 200) =~ "This book is not checked out"
  end
end
