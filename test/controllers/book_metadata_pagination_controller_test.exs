defmodule Bookish.BookMetadataPaginationControllerTest do
  use Bookish.ConnCase

  test "redirects to the metadata index page if given page 1", %{conn: conn} do
    conn = get conn, book_metadata_pagination_path(conn, :index, 1)
    assert redirected_to(conn) == book_metadata_path(conn, :index)
  end

  test "returns an empty page if no records exist on the given page", %{conn: conn} do
    conn = get conn, book_metadata_pagination_path(conn, :index, 2)
    assert conn.status == 200
  end
end
