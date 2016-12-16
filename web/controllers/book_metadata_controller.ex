defmodule Bookish.BookMetadataController do
  use Bookish.Web, :controller

  plug Bookish.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  alias Bookish.BookMetadata
  alias Bookish.Tagging
  alias Bookish.Repository

  def index(conn, _params) do
    render(conn, "index.html", books: Repository.get_metadata, page_count: 1, current_page: 1)
  end

  def show(conn, %{"id" => id}) do
    book_metadata = Repository.get_metadata(id)
    render(conn, "show.html", book_metadata: book_metadata, books: Repository.load_books_from_metadata(book_metadata))
  end

  def create(conn, %{"book_metadata" => book_metadata_params}) do
    changeset = BookMetadata.changeset(%BookMetadata{}, book_metadata_params)

    case Repo.insert(changeset) do
      {:ok, metadata} ->
        metadata
        |> Tagging.update_tags(metadata.tags_list)
        conn
        |> redirect(to: book_metadata_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    book_metadata =
      Repository.get_metadata(id)
      |> Tagging.set_tags_list
    changeset = BookMetadata.changeset(book_metadata)
    render(conn, "edit.html", book_metadata: book_metadata, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book_metadata" => book_metadata_params}) do
    book_metadata = Repository.get_metadata(id)
    changeset = BookMetadata.changeset(book_metadata, book_metadata_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        Tagging.update_tags(book, book.tags_list)
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_metadata_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", book_metadata: book_metadata, changeset: changeset)
    end
  end

  def build_from_book(book) do
    params = %{"title" => book.title,
               "author_firstname" => book.author_firstname,
               "author_lastname" => book.author_lastname,
               "year" => book.year,
               "tags_list" => book.tags_list}
    changeset = BookMetadata.changeset(%BookMetadata{}, params)
    case Repo.insert!(changeset) do
      metadata ->
        Tagging.update_tags(metadata, metadata.tags_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.delete!(Repository.get_metadata(id))
    conn
    |> put_flash(:info, "Book metadata deleted successfully.")
    |> redirect(to: book_metadata_path(conn, :index))
  end
end
