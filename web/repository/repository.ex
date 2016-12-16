defmodule Bookish.Repository do
  alias Bookish.Repo
  alias Bookish.Book
  alias Bookish.BookMetadata
  alias Bookish.Location
  alias Bookish.Tag

  def get_metadata do
    Repo.all(BookMetadata)
    |> Repo.preload(:tags)
    |> Repo.preload(:books)
  end

  def get_metadata(id) do
    Repo.get!(BookMetadata, id)
    |> Repo.preload(:tags)
    |> Repo.preload(:books)
  end

  def load_books_from_metadata(book_metadata) do
    book_metadata.books
    |> Repo.preload(:location)
    |> set_virtual_attributes
  end

  def get_location_names do
    Location.select_name
    |> Repo.all
  end

  def get_locations do
    Repo.all(Location)
  end

  def get_location(id) do
    Repo.get!(Location, id)
    |> Repo.preload(:books)
  end

  def get_books_from_location(location) do
    location.books
    |> Repo.preload(:tags)
    |> Repo.preload(:location)
  end

  def get_book(id) do
    Repo.get!(Book, id)
    |> Repo.preload(:location)
    |> Repo.preload(:book_metadata)
  end

  def get_checked_out_books do
    Book.get_checked_out(Book)
    |> Repo.all
    |> Repo.preload(:location)
    |> Repo.preload(:book_metadata)
    |> set_virtual_attributes
  end

  def associate_book_with_metadata(book, metadata) do
    book
    |> Repo.preload(:book_metadata)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:book_metadata, metadata)
    |> Repo.update!
  end

  def get_books_for_location_with_metadata(location, metadata) do
    Book
    |> Book.get_books_for_location_with_metadata(location, metadata)
    |> Repo.all
    |> Repo.preload(:location)
  end

  def get_associated_metadata_for_check_out(check_out) do
    book = check_out.book |> Repo.preload(:book_metadata)
    book.book_metadata
  end

  def get_tag(id) do
    Repo.get!(Tag, id)
    |> Repo.preload(:book_metadata)
  end

  def get_metadata_from_tag(tag) do
    tag.book_metadata
    |> Repo.preload(:tags)
    |> Repo.preload(:books)
  end

  defp set_virtual_attributes(coll) do
    coll
    |> Enum.map(&(set_attributes_from_metadata(&1 |> Repo.preload(:book_metadata))))
  end

  defp set_attributes_from_metadata(book) do
    params = %{"checked_out" => Book.checked_out?(book),
               "borrower_name" => Book.borrower_name(book),
               "title" => book.book_metadata.title,
               "author_firstname" => book.book_metadata.author_firstname,
               "author_lastname" => book.book_metadata.author_lastname,
               "year" => book.book_metadata.year}
    changeset = Book.set_virtual_attributes(book, params)
    case Repo.update(changeset) do
      {:ok, book} ->
        book
    end
  end
end
