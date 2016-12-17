defmodule Bookish.RepositoryTest do
  use Bookish.ConnCase

  alias Bookish.BookMetadata
  alias Bookish.Repository
  alias Bookish.Book

  test "Returns a list of book metadata in alphabetical order by title" do
    c = Repo.insert! %BookMetadata{title: "C"} |> preload_metadata_associations
    b = Repo.insert! %BookMetadata{title: "B"} |> preload_metadata_associations
    a = Repo.insert! %BookMetadata{title: "A"} |> preload_metadata_associations

    assert Repository.get_metadata == [a, b, c]
  end

  test "Returns a paginated list of book metadata in alphabetical order by title" do
    c = Repo.insert! %BookMetadata{title: "C"} |> preload_metadata_associations
    b = Repo.insert! %BookMetadata{title: "B"} |> preload_metadata_associations
    a = Repo.insert! %BookMetadata{title: "A"} |> preload_metadata_associations
    d = Repo.insert! %BookMetadata{title: "D"} |> preload_metadata_associations

    assert Repository.get_metadata(1, 2) == [a, b]
    assert Repository.get_metadata(2, 2) == [c, d]
  end

  test "Returns an empty list if there is no metadata" do
    assert Repository.get_metadata(1, 2) == []
  end

  test "Returns a paginated list of books from metadata" do
    metadata = Repo.insert! %BookMetadata{}
    book1 = Repo.insert! %Book{book_metadata: metadata} |> preload_book_associations
    book2 = Repo.insert! %Book{book_metadata: metadata} |> preload_book_associations
    book3 = Repo.insert! %Book{book_metadata: metadata} |> preload_book_associations
    book4 = Repo.insert! %Book{book_metadata: metadata} |> preload_book_associations

    assert Repository.load_books_from_metadata(metadata, 1, 2) == [book1, book2]
    assert Repository.load_books_from_metadata(metadata, 2, 2) == [book3, book4]
  end

  test "Returns an empty list if no entries exist on page" do
    metadata = Repo.insert! %BookMetadata{}

    assert Repository.load_books_from_metadata(metadata, 1, 10) == []
  end

  defp preload_metadata_associations(metadata) do
    metadata
    |> Repo.preload(:books)
    |> Repo.preload(:tags)
  end

  defp preload_book_associations(metadata) do
    metadata
    |> Repo.preload(:location)
  end
end
