defmodule Bookish.BookTest do
  use Bookish.ModelCase

  alias Bookish.Book
  alias Bookish.Location
  import Bookish.TestHelpers

  @valid_attrs %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "title", year: 2016, location_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Book.changeset(%Book{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Book.changeset(%Book{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "title cannot be an empty string" do
    attributes = %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "", year: 2016}
    changeset = Book.changeset(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "author_firstname cannot be an empty string" do
    attributes = %{author_firstname: "", author_lastname: "last name", current_location: "current location", title: "title", year: 2016}
    changeset = Book.changeset(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "author_lastname cannot be an empty string" do
    attributes = %{author_firstname: "first name", author_lastname: "", current_location: "current location", title: "title", year: 2016}
    changeset = Book.changeset(%Book{}, attributes)
    refute changeset.valid?
  end

  test "year must be a four-digit number" do
    attributes = %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "title", year: 42}
    changeset = Book.changeset(%Book{}, attributes)
    refute changeset.valid?
  end

  test "checked_out defaults to false" do
    book = Repo.insert!(%Book{})
    refute book.checked_out
  end

  test "checked_out can be set to true" do
    book = Repo.insert!(%Book{checked_out: true})
    assert book.checked_out
  end

  test "a book has a location" do
    location = Repo.insert! %Location{name: "Chicago"}
    book = Repo.insert! %Book{}
   
    updated_book =  
      book
      |> Repo.preload(:location)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:location, location)
      |> Repo.update!
    
    assert updated_book.location.name == "Chicago"
  end
  
  test "when checking out a book, current_location must be an empty string" do
    attributes = %{current_location: "location"}
    changeset = Book.checkout(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "return is valid with current_location" do
    attributes = %{current_location: "location"}
    changeset = Book.return(%Book{}, attributes)
    assert changeset.valid?
  end

  test "when returning a book, current location must not be an empty string" do
    attributes = %{current_location: ""}
    changeset = Book.return(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "checked_out? returns false if no check_out record exists for the book" do
    book = Repo.insert! %Book{}

    refute Book.checked_out?(book)
  end

  test "checked_out? returns true if a check_out record exists for the book" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)

    assert Book.checked_out?(book)
  end

  test "checked out books returns an empty list if no books are checked out" do
    Repo.insert! %Book{}

    assert empty? Book.get_checked_out(Book) |> Repo.all
  end

  test "get_checked_out queries books that are checked out" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)

    assert List.first(Book.get_checked_out(Book) |> Repo.all) == book
  end

  test "get_checked_out returns an empty collection if there are no books to query" do
    assert empty? Book.get_checked_out(Book) |> Repo.all
  end
  
  test "get_checked_out returns books checked out by user id" do
    book1 = Repo.insert! %Book{current_location: "book 1"}
    check_out =
      Ecto.build_assoc(book1, :check_outs, borrower_id: "1")
    Repo.insert!(check_out)
    
    book2 = Repo.insert! %Book{current_location: "book 2"}
    check_out =
      Ecto.build_assoc(book2, :check_outs, borrower_id: "2")
    Repo.insert!(check_out)

    books = 
      Book
      |> Book.get_checked_out("1")
      |> Repo.all

    assert books == [book1]
  end
 
  test "borrower_name returns the name of the person the book is checked out to" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)
 
    assert Book.borrower_name(book) == "Person"
  end
 
  test "borrower_name returns nil if the book is currently available" do
    book = Repo.insert! %Book{}

    assert is_nil(Book.borrower_name(book))
  end
  #
  #  test "sorted_by_title query returns a list of books sorted by title" do
  #    b = Repo.insert!(%Book{title: "B"})
  #    a = Repo.insert!(%Book{title: "A"})
  #    c = Repo.insert!(%Book{title: "C"})
  #
  #    expectedList = [a, b, c]
  #
  #    refute Repo.all(Book) == expectedList
  #    assert Book |> Book.sorted_by_title |> Repo.all == expectedList
  #  end
  #
  #  test "get_by_letter returns all books with titles starting with a certain letter do" do
  #    a = Repo.insert!(%Book{title: "A"})
  #    b = Repo.insert!(%Book{title: "B"})
  #
  #    assert Book |> Book.get_by_letter("A") |> Repo.all == [a]
  #    assert Book |> Book.get_by_letter("b") |> Repo.all == [b]
  #    assert Book |> Book.get_by_letter("C") |> Repo.all == []
  #  end
  #  
  test "paginate returns the number of entries offset by the page number" do
    for _ <- 1..12 do Repo.insert!(%Book{}) end
    entries_per_page = 10
    page_1 = 
      Book
      |> Book.paginate(1, entries_per_page)
      |> Repo.all
    page_1_count = length(page_1)

    assert page_1_count == 10

    page_2 = 
      Book
      |> Book.paginate(2, entries_per_page)
      |> Repo.all
    page_2_count = length(page_2)

    assert page_2_count == 2
  end
  
  test "count returns the number of results in a query" do
    for _ <- 1..5 do Repo.insert!(%Book{}) end
    count = 
      Book
      |> Book.count
      |> Repo.all
      |> List.first

    assert count == 5
  end
end
