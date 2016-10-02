defmodule Bookish.CheckOutControllerTest do
  use Bookish.ConnCase

  alias Bookish.CheckOut
  alias Bookish.Book
  @valid_attrs %{checked_out_to: "A person"}
  @invalid_attrs %{}
  
  test "lists all entries on index", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = get conn, book_check_out_path(conn, :index, book)
    assert html_response(conn, 200) =~ "Listing check outs"
  end

  test "renders form to check out a book", %{conn: conn} do
    book = Repo.insert! %Book{} 
    conn = get conn, book_check_out_path(conn, :new, book)
    assert conn.status == 200 
  end

  test "creates new check-out record and redirects when data is valid", %{conn: conn} do
    book = Repo.insert! %Book{} 
    conn = post conn, book_check_out_path(conn, :create, book), check_out: @valid_attrs
    assert redirected_to(conn) == book_path(conn, :index)
    assert Repo.get_by(CheckOut, @valid_attrs)
  end

  test "does not create new check-out record and renders errors when data is invalid", %{conn: conn} do
    book = Repo.insert! %Book{}
    conn = post conn, book_check_out_path(conn, :create, book), check_out: @invalid_attrs
    refute Repo.get_by(CheckOut, @invalid_attrs)
    assert conn.status == 200
  end

  test "does not show new check-out page if a book is already checked out and redirects to the index", %{conn: conn} do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)
    conn = get conn, book_check_out_path(conn, :new, book)
    assert redirected_to(conn) == book_path(conn, :index)
  end

  test "does not create a new check-out record if a book is already checked out", %{conn: conn} do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")

    Repo.insert!(check_out)
    post conn, book_check_out_path(conn, :create, book), check_out: @valid_attrs

    refute Repo.get_by(CheckOut, @valid_attrs)
  end
end
