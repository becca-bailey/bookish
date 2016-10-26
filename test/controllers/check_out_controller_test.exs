defmodule Bookish.CheckOutControllerTest do
  use Bookish.ConnCase

  alias Bookish.CheckOut
  alias Bookish.Book
  @user %{id: 1, name: "user"}
  @valid_attrs %{"book_id": 1}
  @invalid_attrs %{}
  
  test "does not allow a non-logged-in user to check out a book" do
    book = Repo.insert! %Book{}  

    conn = get build_conn, book_check_out_path(build_conn, :new, book)

    assert redirected_to(conn) == "/"
  end

  test "creates new check-out record and redirects when data is valid", %{conn: conn} do
    book = Repo.insert! %Book{} 

    conn = 
      conn
      |> assign(:current_user, @user)
      |> post(book_check_out_path(conn, :create, book), check_out: @valid_attrs)

    assert redirected_to(conn) == book_path(conn, :index)
  end

  test "does not create a new check-out record if a book is already checked out", %{conn: conn} do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")

    Repo.insert!(check_out)
    
    conn
    |> assign(:current_user, @user)
    |> post(book_check_out_path(conn, :create, book), check_out: @valid_attrs)

    refute Repo.get_by(CheckOut, @valid_attrs)
  end

  test "does not allow a non-logged in user to check out a book", %{conn: conn} do
    book = Repo.insert! %Book{}

    conn = post conn, book_check_out_path(conn, :create, book), check_out: @valid_attrs

    assert redirected_to(conn) == "/"
  end
end
