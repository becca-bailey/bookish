defmodule Bookish.BookMetadataTest do
  use Bookish.ModelCase

  alias Bookish.BookMetadata

  @valid_attrs %{author_firstname: "first name", author_lastname: "last name", title: "title", year: 2016}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BookMetadata.changeset(%BookMetadata{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BookMetadata.changeset(%BookMetadata{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "title cannot be an empty string" do
    attributes = %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "", year: 2016}
    changeset = BookMetadata.changeset(%BookMetadata{}, attributes)
    refute changeset.valid?
  end
  
  test "author_firstname cannot be an empty string" do
    attributes = %{author_firstname: "", author_lastname: "last name", current_location: "current location", title: "title", year: 2016}
    changeset = BookMetadata.changeset(%BookMetadata{}, attributes)
    refute changeset.valid?
  end
  
  test "author_lastname cannot be an empty string" do
    attributes = %{author_firstname: "first name", author_lastname: "", current_location: "current location", title: "title", year: 2016}
    changeset = BookMetadata.changeset(%BookMetadata{}, attributes)
    refute changeset.valid?
  end

  test "year must be a four-digit number" do
    attributes = %{author_firstname: "first name", author_lastname: "last name", current_location: "current location", title: "title", year: 42}
    changeset = BookMetadata.changeset(%BookMetadata{}, attributes)
    refute changeset.valid?
  end
end
