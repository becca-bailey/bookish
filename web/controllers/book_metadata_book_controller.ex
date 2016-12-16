defmodule Bookish.BookMetadataBookController do
  use Bookish.Web, :controller

  plug Bookish.Plugs.RequireAuth when action in [:new, :create]

  alias Bookish.BookMetadata
  alias Bookish.Book
  alias Bookish.Location

  def new(conn, %{"book_metadata_id" => id}) do
    metadata = Repo.get!(BookMetadata, id)
    changeset = Book.changeset(%Book{})
    render(conn, "new.html", changeset: changeset, locations: get_locations, metadata: metadata)
  end

  def create(conn, %{"book_metadata_id" => id, "book" => book_params}) do
    metadata = Repo.get(BookMetadata, id)
    changeset = Book.with_existing_metadata(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        book
        |> associate_metadata(metadata)

        conn
        |> put_flash(:info, "Copy has been created!")
        |> redirect(to: book_metadata_path(conn, :show, metadata))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, locations: get_locations, metadata: metadata)
    end
  end

  def edit(conn, %{"book_metadata_id" => book_metadata_id, "id" => id}) do
    book =
      Repo.get!(Book, id)
      |> preload_associations
    changeset = Book.with_existing_metadata(book)
    render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
  end

  def update(conn, %{"book_metadata_id" => book_metadata_id, "id" => id, "book" => book_params}) do
    book_metadata = Repo.get!(BookMetadata, book_metadata_id)
    book =
      Repo.get!(Book, id)
      |> Repo.preload(:location)
    changeset = Book.with_existing_metadata(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_metadata_path(conn, :show, book_metadata))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
    end
  end


  # Shared with BookController

  defp get_locations do
    Location.select_name
    |> Repo.all
  end

  defp associate_metadata(book, metadata) do
    book
    |> Repo.preload(:book_metadata)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:book_metadata, metadata)
    |> Repo.update!
  end

  defp preload_associations(coll) do
    coll
    |> Repo.preload(:location)
    |> Repo.preload(:book_metadata)
  end

end
