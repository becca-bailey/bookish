defmodule Bookish.CirculationTest do
  use Bookish.ConnCase

  alias Bookish.Circulation 
  alias Bookish.Book

  @book_attrs %{author_firstname: "some content", author_lastname: "some content", current_location: "some content", title: "some content", year: 2016}

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
end

