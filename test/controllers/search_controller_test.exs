defmodule Bookish.SearchControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book

  test "lists books by letter", %{conn: conn} do
    Repo.insert! %Book{title: "A brief history of programming"}
    Repo.insert! %Book{title: "Something else"}

    conn = get conn, search_path(conn, :index_by_letter, "A")

    assert html_response(conn, 200) =~ "A brief history of programming"
    refute html_response(conn, 200) =~ "Something else"
  end
end
