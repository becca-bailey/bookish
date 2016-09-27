defmodule Bookish.PageControllerTest do
  use Bookish.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Add a book"
    assert html_response(conn, 200) =~ "Look for a book"
    assert html_response(conn, 200) =~ "Return a book"
  end
end
