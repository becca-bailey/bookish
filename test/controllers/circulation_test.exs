defmodule Bookish.CirculationTest do
  use Bookish.ConnCase

  alias Bookish.Circulation 
  alias Bookish.Book
  alias Bookish.CheckOut
  alias Bookish.TestHelpers, as: Helpers

  @book_attrs %{author_firstname: "some content", author_lastname: "some content", current_location: "some content", title: "some content", year: 2016}

  @user %{id: 1, name: "user"}

  test "renders checked_out page", %{conn: conn} do
    conn = get conn, "/books/checked_out"
    assert conn.status == 200
  end

  test "shows a form to return a book", %{conn: conn} do
    book = Repo.insert! %Book{}

    conn = 
      conn
      |> assign(:current_user, @user)
      |> get(circulation_path(conn, :return, book))

    assert conn.status == 200
  end

   test "does not allow a non-logged-in user to return a book" do
     book = Repo.insert! %Book{}  

     conn = get build_conn, circulation_path(build_conn, :return, book)

     assert redirected_to(conn) == "/"
   end

  test "checked_out renders only books that are checked out", %{conn: conn} do
    checked_out_book = Repo.insert! %Book{title: "This book is checked out"}  
    Repo.insert! %Book{title: "This book is not checked out"}

    check_out = 
      Ecto.build_assoc(checked_out_book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)

    conn = get conn, circulation_path(conn, :checked_out)
    assert html_response(conn, 200) =~ "This book is checked out"
    refute html_response(conn, 200) =~ "This book is not checked out"
  end

  test "checked_out displays the name of the person who has checked out the book", %{conn: conn} do
    checked_out_book = Repo.insert! %Book{title: "This book is checked out"}  

    check_out = 
      Ecto.build_assoc(checked_out_book, :check_outs, checked_out_to: "Becca")
    Repo.insert!(check_out)

    conn = get conn, circulation_path(conn, :checked_out)
    assert html_response(conn, 200) =~ "Becca"
    refute html_response(conn, 200) =~ "This book is not checked out"
  end

  test "checked_out? returns false if no check_out record exists for the book" do
    book = Repo.insert! %Book{} 

    refute Circulation.checked_out?(book)
  end
  
  test "checked_out? returns true if a check_out record exists for the book" do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)

    assert Circulation.checked_out?(book) 
  end

  test "checked_out_to returns the name of the person the book is checked out to" do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)

    assert Circulation.checked_out_to(book) == "Person"
  end

  test "checked_out_to returns nil if the book is currently available" do
    book = Repo.insert! %Book{}

    assert is_nil(Circulation.checked_out_to(book))
  end

  test "set virtual attributes returns an unchanged collection of books if no books are checked out" do
    book = Repo.insert! %Book{}
    coll = [book]

    assert Circulation.set_virtual_attributes(coll) == coll
  end

  test "check_out updates the current location and returns the changed book", %{conn: conn} do
    book = Repo.insert! %Book{"current_location": "A place"}
    conn = post conn, book_check_out_path(conn, :create, book), check_out: %{"checked_out_to": "Person"} 
    updated_book = Circulation.check_out(conn)

    assert is_nil(updated_book.current_location) 
  end

  test "if a check-out record exists for a book in the collection, it returns an updated collection" do
    book = Repo.insert! %Book{}
    coll = [book]
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)
    updated_coll = Circulation.set_virtual_attributes(coll)

    assert List.first(updated_coll).checked_out == true
    assert List.first(updated_coll).checked_out_to == "Person"
  end

  test "checked out books returns an empty list if no books are checked out" do
    Repo.insert! %Book{}
    
    assert Helpers.empty? Circulation.get_checked_out(Book) |> Repo.all 
  end

  test "get_checked_out queries resources that are checked out" do
    book = Repo.insert! %Book{}
    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)
    
    assert List.first(Circulation.get_checked_out(Book) |> Repo.all) == book
  end

  test "get_checked_out returns an empty collection if there are no books to query" do
    assert Helpers.empty? Circulation.get_checked_out(Book) |> Repo.all
  end
  
  test "updates the current location when returning a book with a valid location", %{conn: conn} do
    book = Repo.insert! %Book{}  
    location = "Chicago"

    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    Repo.insert!(check_out)

    conn = 
      conn
      |> assign(:current_user, @user)
      |> post(circulation_path(conn, :process_return, book), book: %{current_location: location})

    assert redirected_to(conn) == book_path(conn, :index)
    assert Repo.get(Book, book.id).current_location == location 
  end

  test "adds a return date to a check_out record when returning a book", %{conn: conn} do
    book = Repo.insert! %Book{}  
    location = "Chicago"

    check_out = 
      Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
      |> Repo.insert!

    conn
    |> assign(:current_user, @user)
    |> post(circulation_path(conn, :process_return, book), book: %{current_location: location})

    assert Repo.get(CheckOut, check_out.id).return_date
  end

  test "once a book is returned, it is no longer checked out", %{conn: conn} do
    book = Repo.insert! %Book{}
    Ecto.build_assoc(book, :check_outs, checked_out_to: "Person")
    |> Repo.insert!

    assert Circulation.set_attributes(book).checked_out

    conn
    |> assign(:current_user, @user)
    |> post(circulation_path(conn, :process_return, book), book: %{current_location: "Chicago"})
    
    refute Circulation.set_attributes(book).checked_out
  end
end

