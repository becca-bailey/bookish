defmodule Bookish.BooksControllerTest do
  use Bookish.ConnCase

  test "GET /books", %{conn: conn} do
    conn = get conn, "/books"
    assert conn.status == 200
  end

  test "GET /books/new", %{conn: conn} do
    conn = get conn, "/books/new"
    assert conn.status == 200
  end

  test "GET /books/return", %{conn: conn} do
    conn = get conn, "/books/return"
    assert conn.status == 200
  end
end
