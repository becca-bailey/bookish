defmodule Bookish.BookMetadataBookController do
  use Bookish.Web, :controller

  plug Bookish.Plugs.RequireAuth when action in [:new, :create]

  alias Bookish.Book
  alias Bookish.Repository

  def new(conn, %{"book_metadata_id" => id}) do
    changeset = Book.changeset(%Book{})
    render(conn, "new.html", changeset: changeset, locations: Repository.get_location_names, metadata: Repository.get_metadata(id))
  end

  def create(conn, %{"book_metadata_id" => id, "book" => book_params}) do
    metadata = Repository.get_metadata(id)
    changeset = Book.with_existing_metadata(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        book
        |> Repository.associate_book_with_metadata(metadata)

        conn
        |> put_flash(:info, "Copy has been created!")
        |> redirect(to: book_metadata_path(conn, :show, metadata))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, locations: Repository.get_location_names, metadata: metadata)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = Repository.get_book(id)
    changeset = Book.with_existing_metadata(book)
    render(conn, "edit.html", book: book, changeset: changeset, locations: Repository.get_location_names)
  end

  def update(conn, %{"book_metadata_id" => book_metadata_id, "id" => id, "book" => book_params}) do
    book_metadata = Repository.get_metadata(book_metadata_id)
    book = Repository.get_book(id)
    changeset = Book.with_existing_metadata(book, book_params)

    case Repo.update(changeset) do
      {:ok, _book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_metadata_path(conn, :show, book_metadata))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset, locations: Repository.get_location_names)
    end
  end
end
