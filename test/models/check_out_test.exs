defmodule Bookish.CheckOutTest do
  use Bookish.ModelCase
  import Bookish.TestHelpers

  alias Bookish.CheckOut
  alias Bookish.Book

  @valid_attrs %{borrower_name: "A person", book_id: 1, borrower_id: "email"}
  @invalid_attrs %{}

  #  test "check-out is valid with borrower_name and book_id" do
  #    changeset = CheckOut.changeset(%CheckOut{}, @valid_attrs)
  #    assert changeset.valid?
  #  end

  test "check-out is invalid with no attributes" do
    changeset = CheckOut.changeset(%CheckOut{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "current returns collection of current check_outs" do
    check_out = Repo.insert!(%CheckOut{})
    current_check_out = List.first(CheckOut.current(CheckOut) |> Repo.all)

    assert current_check_out == check_out
  end

  test "current returns an empty collection if no books are checked out" do
    {:ok, date} = Ecto.Date.cast(DateTime.utc_now())
    Repo.insert!(%CheckOut{return_date: date})
    assert empty? CheckOut.current(CheckOut) |> Repo.all 
  end

  test "current will return an entry for a single book that is checked out" do
    book = Repo.insert! %Book{}
    association =
      Ecto.build_assoc(book, :check_outs, borrower_name: "Person")
    check_out = Repo.insert!(association)
    current_check_out = List.first(CheckOut.current(CheckOut, book.id) |> Repo.all)

    assert current_check_out == check_out
  end
end
