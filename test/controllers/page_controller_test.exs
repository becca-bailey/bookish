defmodule Bookish.PageControllerTest do
  use Bookish.ConnCase

  test "index contains link to add a book", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "/books/new"
    assert html_response(conn, 200) =~ "Return a book"
  end

  test "index contains link to look for a book", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "/books"
  end

  test "index contains link to return a book", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "/books/checked_out"
  end
end
