defmodule Bookish.BookControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  @valid_attrs %{author_firstname: "some content", author_lastname: "some content", current_location: "some content", title: "some content", year: 2016}
  @invalid_attrs %{}

  test "renders return page", %{conn: conn} do
    conn = get conn, "/books/return"
    assert conn.status == 200
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, book_path(conn, :index)
    assert conn.status == 200
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, book_path(conn, :new)
    assert html_response(conn, 200) =~ "New book"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, book_path(conn, :create), book: @valid_attrs
    assert redirected_to(conn) == book_path(conn, :index)
    assert Repo.get_by(Book, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, book_path(conn, :create), book: @invalid_attrs
    assert html_response(conn, 200) =~ "New book"
  end

  test "shows chosen resource", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = get conn, book_path(conn, :show, book)
    assert html_response(conn, 200) =~ "Show book"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, book_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = get conn, book_path(conn, :edit, book)
    assert html_response(conn, 200) =~ "Edit book"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = put conn, book_path(conn, :update, book), book: @valid_attrs
    assert redirected_to(conn) == book_path(conn, :show, book)
    assert Repo.get_by(Book, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = put conn, book_path(conn, :update, book), book: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit book"
  end

  test "deletes chosen resource", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = delete conn, book_path(conn, :delete, book)
    assert redirected_to(conn) == book_path(conn, :index)
    refute Repo.get(Book, book.id)
  end
end
