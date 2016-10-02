defmodule Bookish.BookTest do
  use Bookish.ModelCase

  alias Bookish.Book

  @valid_attrs %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "title", year: 2016}
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

  @tag :checkout
  test "current_location must be an empty string" do
    attributes = %{current_location: "location"}
    changeset = Book.checkout(%Book{}, attributes)
    refute changeset.valid?
  end
  
  @tag :return
  test "return is valid with current_location" do
    attributes = %{current_location: "location"}
    changeset = Book.return(%Book{}, attributes)
    assert changeset.valid?
  end

  @tag :return
  test "current location must not be an empty string" do
    attributes = %{current_location: ""}
    changeset = Book.return(%Book{}, attributes)
    refute changeset.valid?
  end
end
