defmodule Bookish.BookController do
  use Bookish.Web, :controller
  
  plug Bookish.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  alias Bookish.Book
  alias Bookish.Tagging
  alias Bookish.Location
  alias Bookish.PaginationController
  alias Bookish.BookMetadataController
  alias Bookish.BookMetadata

  def index(conn, _params) do
    PaginationController.show_pages(conn, %{"number" => "1"})
  end

  def new_with_existing_metadata(conn, %{"book_metadata_id" => id}) do
    metadata = Repo.get!(BookMetadata, id)
    changeset = Book.changeset(%Book{}) 
    render(conn, "new_with_existing_metadata.html", changeset: changeset, locations: get_locations, metadata: metadata) 
  end

  def new(conn, _params) do
    changeset = Book.changeset(%Book{}) 
    render(conn, "new.html", changeset: changeset, locations: get_locations)
  end

  def show(conn, %{"id" => id}) do
  end

  def create(conn, %{"book" => book_params}) do
    changeset = Book.changeset(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        metadata = BookMetadataController.build_from_book book 
        associate_metadata(book, metadata)

        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: book_metadata_path(conn, :show, metadata))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, locations: get_locations)
    end
  end

  def create_with_existing_metadata(conn, %{"book_metadata_id" => metadata_id, "book" => book_params}) do
    metadata = Repo.get(BookMetadata, metadata_id)
    changeset = Book.with_existing_metadata(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        book 
        |> associate_metadata(metadata)

        conn
        |> put_flash(:info, "Book has been created!")
        |> redirect(to: book_metadata_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new_with_existing_metatags.html", changeset: changeset, location: get_locations, metadata: metadata)
    end
  end

  defp associate_metadata(book, metadata) do
    book
    |> Repo.preload(:book_metadata)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:book_metadata, metadata)
    |> Repo.update!
  end

  def edit(conn, %{"id" => id}) do
    book = 
      Repo.get!(Book, id) 
      |> preload_associations
    changeset = Book.with_existing_metadata(book)
    render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = 
      Repo.get!(Book, id) 
      |> Repo.preload(:location)
    changeset = Book.with_existing_metadata(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_metadata_path(conn, :show, get_metadata(book |> Repo.preload(:book_metadata))))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
    end
  end

  defp get_metadata(book) do
    book.book_metadata
  end

  def delete(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    Repo.delete!(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: book_metadata_path(conn, :show, get_metadata(book |> Repo.preload(:book_metadata))))
  end
  
  def checked_out(conn, _params) do
    books = 
      Book.get_checked_out(Book) 
      |> Repo.all
      |> preload_associations
      |> set_virtual_attributes
    render(conn, "checked_out.html", books: books)
  end

  defp get_locations do
    Location.select_name 
    |> Repo.all
  end
  
  def load_from_query(query) do
    query
    |> Repo.all
    |> preload_associations
    |> set_virtual_attributes 
  end
  
  defp preload_associations(coll) do
    coll
    |> Repo.preload(:location)
    |> Repo.preload(:book_metadata)
  end
  
  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  def set_attributes(book) do
    params = %{"checked_out" => Book.checked_out?(book), "borrower_name" => Book.borrower_name(book), "title" => get_title(book), "author_firstname" => get_author_firstname(book), "author_lastname" => get_author_lastname(book), "year" => get_year(book)}
    changeset = Book.set_virtual_attributes(book, params)
    case Repo.update(changeset) do
      {:ok, book} ->
        book
    end
  end

  #temporary

  defp get_title(book) do
    if book.book_metadata do
      book.book_metadata.title
    else
      "No title"
    end
  end

  defp get_author_firstname(book) do
    if book.book_metadata do
      book.book_metadata.author_firstname
    else
      "No first name"
    end
  end
  
  defp get_author_lastname(book) do
    if book.book_metadata do
      book.book_metadata.author_lastname
    else
      "No last name"
    end
  end

  defp get_year(book) do
    if book.book_metadata do
      book.book_metadata.year
    else
      2016 
    end
  end
end
