defmodule Bookish.ResourceTest do
  use Bookish.ConnCase
  
  alias Bookish.Resource
  alias Bookish.Book
  import Bookish.TestHelpers
  
  test "when checking out a resource, current_location must be an empty string" do
    attributes = %{current_location: "location"}
    changeset = Resource.checkout(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "return is valid with current_location" do
    attributes = %{current_location: "location"}
    changeset = Resource.return(%Book{}, attributes)
    assert changeset.valid?
  end

  test "when returning a resource, current location must not be an empty string" do
    attributes = %{current_location: ""}
    changeset = Resource.return(%Book{}, attributes)
    refute changeset.valid?
  end
  
  test "checked_out? returns false if no check_out record exists for the book" do
    book = Repo.insert! %Book{}

    refute Resource.checked_out?(book)
  end

  test "checked_out? returns true if a check_out record exists for the book" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)

    assert Resource.checked_out?(book)
  end

  test "checked out books returns an empty list if no books are checked out" do
    Repo.insert! %Book{}

    assert empty? Resource.get_checked_out(Book) |> Repo.all
  end

  test "get_checked_out queries resources that are checked out" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)

    assert List.first(Resource.get_checked_out(Book) |> Repo.all) == book
  end

  test "get_checked_out returns an empty collection if there are no books to query" do
    assert empty? Resource.get_checked_out(Book) |> Repo.all
  end
  
  test "get_checked_out returns books checked out by user id" do
    book1 = Repo.insert! %Book{title: "book 1"}
    check_out =
      Ecto.build_assoc(book1, :check_outs, borrower_id: "1")
    Repo.insert!(check_out)
    
    book2 = Repo.insert! %Book{title: "book 2"}
    check_out =
      Ecto.build_assoc(book2, :check_outs, borrower_id: "2")
    Repo.insert!(check_out)

    books = 
      Book
      |> Resource.get_checked_out("1")
      |> Repo.all

    assert books == [book1]
  end

  test "borrower_name returns the name of the person the book is checked out to" do
    book = Repo.insert! %Book{}
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)

    assert Resource.borrower_name(book) == "Person"
  end

  test "borrower_name returns nil if the book is currently available" do
    book = Repo.insert! %Book{}

    assert is_nil(Resource.borrower_name(book))
  end

  test "sorted_by_title query returns a list of books sorted by title" do
    b = Repo.insert!(%Book{title: "B"})
    a = Repo.insert!(%Book{title: "A"})
    c = Repo.insert!(%Book{title: "C"})

    expectedList = [a, b, c]

    refute Repo.all(Book) == expectedList
    assert Book |> Resource.sorted_by_title |> Repo.all == expectedList
  end

  test "get_by_letter returns all books with titles starting with a certain letter do" do
    a = Repo.insert!(%Book{title: "A"})
    b = Repo.insert!(%Book{title: "B"})

    assert Book |> Resource.get_by_letter("A") |> Repo.all == [a]
    assert Book |> Resource.get_by_letter("b") |> Repo.all == [b]
    assert Book |> Resource.get_by_letter("C") |> Repo.all == []
  end
  
  test "paginate returns the number of entries offset by the page number" do
    for _ <- 1..12 do Repo.insert!(%Book{}) end
    entries_per_page = 10
    page_1 = 
      Book
      |> Resource.paginate(1, entries_per_page)
      |> Repo.all
    page_1_count = length(page_1)

    assert page_1_count == 10

    page_2 = 
      Book
      |> Resource.paginate(2, entries_per_page)
      |> Repo.all
    page_2_count = length(page_2)

    assert page_2_count == 2
  end
  
  test "count returns the number of results in a query" do
    for _ <- 1..5 do Repo.insert!(%Book{}) end
    count = 
      Book
      |> Resource.count
      |> Repo.all
      |> List.first

    assert count == 5
  end

end
