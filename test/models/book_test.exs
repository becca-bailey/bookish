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

  @tag :checkout
  test "checkout is valid with checked_out and checked_out_to" do
    attributes = %{checked_out: true, checked_out_to: "name", current_location: ""}
    changeset = Book.checkout(%Book{}, attributes)
    assert changeset.valid?
  end

  @tag :checkout
  test "checked out must be true" do
    attributes = %{checked_out: false, checked_out_to: "name", current_location: ""}
    changeset = Book.checkout(%Book{}, attributes)
    refute changeset.valid?
  end

  @tag :checkout
  test "checked_out_to must not be an empty string" do
    attributes = %{checked_out: true, checked_out_to: "", current_location: ""}
    changeset = Book.checkout(%Book{}, attributes)
    refute changeset.valid?
  end

  @tag :checkout
  test "current_location must be an empty string" do
    attributes = %{checked_out: true, checked_out_to: "", current_location: "location"}
    changeset = Book.checkout(%Book{}, attributes)
    refute changeset.valid?
  end
  
  @tag :return
  test "return is valid with checked_out and current_location" do
    attributes = %{checked_out: false, checked_out_to: "", current_location: "location"}
    changeset = Book.return(%Book{}, attributes)
    assert changeset.valid?
  end

  @tag :return
  test "checked out must be false" do
    attributes = %{checked_out: true, checked_out_to: "", current_location: "location"}
    changeset = Book.return(%Book{}, attributes)
    refute changeset.valid?
  end

  @tag :return
  test "checked_out_to must be an empty string" do
    attributes = %{checked_out: false, checked_out_to: "name", current_location: "location"}
    changeset = Book.return(%Book{}, attributes)
    refute changeset.valid?
  end

  @tag :return
  test "current location must not be an empty string" do
    attributes = %{checked_out: false, checked_out_to: "name", current_location: ""}
    changeset = Book.return(%Book{}, attributes)
    refute changeset.valid?
  end
end
