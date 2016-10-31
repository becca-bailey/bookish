defmodule Bookish.ResourceControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  alias Bookish.ResourceController

  test "set virtual attributes returns an unchanged collection of books if no books are checked out" do
    book = Repo.insert! %Book{}
    coll = [book]

    assert ResourceController.set_virtual_attributes(coll) == coll
  end

  test "if a check-out record exists for a book in the collection, it returns an updated collection" do
    book = Repo.insert! %Book{}
    coll = [book]
    check_out =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    Repo.insert!(check_out)
    updated_coll = ResourceController.set_virtual_attributes(coll)

    assert List.first(updated_coll).checked_out == true
    assert List.first(updated_coll).borrower_name == "Person"
  end

end

