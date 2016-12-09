defmodule Bookish.ReturnControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  alias Bookish.BookController

  @user %{id: "email", name: "user"}

  #  test "shows a form to return a book", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    Ecto.build_assoc(book, :check_outs, borrower_name: "Person", borrower_id: @user.id)
  #    |> Repo.insert!
  #
  #    conn =
  #      conn
  #      |> assign(:current_user, @user)
  #      |> get(return_path(conn, :return, book))
  #
  #    assert conn.status == 200
  #  end
  #  
  #  test "only a user with a matching id can return a book", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    Ecto.build_assoc(book, :check_outs, borrower_name: "Person", borrower_id: "different email")
  #    |> Repo.insert!
  #  
  #    conn = 
  #      conn
  #      |> assign(:current_user, @user)
  #      |> get(return_path(conn, :return, book))
  #  
  #     assert redirected_to(conn) == "/books"
  #  end
  #
  #  test "only a logged-in user can return a book", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    Ecto.build_assoc(book, :check_outs, borrower_name: "Person", borrower_id: "different email")
  #    |> Repo.insert!
  #
  #    conn = post conn, return_path(conn, :process_return, book), book: %{current_location: "location"} 
  #    
  #    assert redirected_to(conn) == "/"
  #  end
  #   
  #  test "updates the current location when returning a book with a valid location", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    location = "Chicago"
  #  
  #    check_out =
  #      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
  #    Repo.insert!(check_out)
  #  
  #    conn =
  #      conn
  #      |> assign(:current_user, @user)
  #      |> post(return_path(conn, :process_return, book), book: %{current_location: location})
  #  
  #    assert redirected_to(conn) == book_path(conn, :index)
  #    assert Repo.get(Book, book.id).current_location == location
  #  end
  #  
  #  test "adds a return date to a check_out record when returning a book", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    location = "Chicago"
  #  
  #    check_out =
  #      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
  #      |> Repo.insert!
  #  
  #    conn
  #    |> assign(:current_user, @user)
  #    |> post(return_path(conn, :process_return, book), book: %{current_location: location})
  #  
  #    assert Repo.get(Bookish.CheckOut, check_out.id).return_date
  #  end
  #  
  #  test "once a book is returned, it is no longer checked out", %{conn: conn} do
  #    book = Repo.insert! %Book{}
  #    Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
  #    |> Repo.insert!
  #  
  #    assert BookController.set_attributes(book).checked_out
  #  
  #    conn
  #    |> assign(:current_user, @user)
  #    |> post(return_path(conn, :process_return, book), book: %{current_location: "Chicago"})
  #  
  #    refute BookController.set_attributes(book).checked_out
  #  end
end
