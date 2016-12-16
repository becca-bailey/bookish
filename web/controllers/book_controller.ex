defmodule Bookish.BookController do
  use Bookish.Web, :controller

  plug Bookish.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  alias Bookish.Book
  alias Bookish.Location
  alias Bookish.PaginationController
  alias Bookish.BookMetadataController
  alias Bookish.Repository

  def index(conn, _params) do
    PaginationController.show_pages(conn, %{"number" => "1"})
  end

  def new(conn, _params) do
    changeset = Book.changeset(%Book{})
    render(conn, "new.html", changeset: changeset, locations: get_locations)
  end

  def create(conn, %{"book" => book_params}) do
    changeset = Book.changeset(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        metadata = BookMetadataController.build_from_book book
        Repository.associate_book_with_metadata(book, metadata)

        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: book_metadata_path(conn, :show, metadata))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, locations: get_locations)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = Repository.get_book(id)
    changeset = Book.with_existing_metadata(book)
    render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Repository.get_book(id)
    changeset = Book.with_existing_metadata(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_metadata_path(conn, :show, book.book_metadata))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Repository.get_book(id)
    Repo.delete!(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: book_metadata_path(conn, :show, book.book_metadata))
  end

  def checked_out(conn, _params) do
    render(conn, "checked_out.html", books: Repository.get_checked_out_books)
  end

  def set_attributes(book) do
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

  defp get_locations do
    Location.select_name
    |> Repo.all
  end

  defp preload_associations(coll) do
    coll
    |> Repo.preload(:location)
    |> Repo.preload(:book_metadata)
  end

  defp set_virtual_attributes(coll) do
    coll
    |> Enum.map(&(set_attributes(&1)))
  end
end
