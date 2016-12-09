defmodule Bookish.BookMetadataController do
  use Bookish.Web, :controller

  alias Bookish.BookMetadata
  alias Bookish.Tagging

  def index(conn, _params) do
    book_records = Repo.all(BookMetadata) 
                   |> Repo.preload(:tags) 
                   |> Repo.preload(:books)
    render(conn, "index.html", books: book_records, page_count: 1, current_page: 1)
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

  def show(conn, %{"id" => id}) do
    book_metadata = Repo.get!(BookMetadata, id) |> Repo.preload(:books)
    render(conn, "show.html", book_metadata: book_metadata, books: book_metadata.books |> Repo.preload(:location))
  end

  def build_from_book(book) do
    params = %{"title" => book.title, "author_firstname" => book.author_firstname, "author_lastname" => book.author_lastname, "year" => book.year , "tags_list" => book.tags_list}
    changeset = BookMetadata.changeset(%BookMetadata{}, params) 
    case Repo.insert!(changeset) do
      metadata ->
        metadata
        |> Tagging.update_tags(metadata.tags_list)
    end
  end

  def edit(conn, %{"id" => id}) do
    book_metadata = Repo.get!(BookMetadata, id)
    changeset = BookMetadata.changeset(book_metadata)
    render(conn, "edit.html", book_metadata: book_metadata, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book_metadata" => book_metadata_params}) do
    book_metadata = Repo.get!(BookMetadata, id)
    changeset = BookMetadata.changeset(book_metadata, book_metadata_params)

    case Repo.update(changeset) do
      {:ok, book} -> 
        conn
        |> redirect(to: book_metadata_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", book_metadata: book_metadata, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book_metadata = Repo.get!(BookMetadata, id)
    Repo.delete!(book_metadata)

    conn
    |> put_flash(:info, "Book metadata deleted successfully.")
    |> redirect(to: book_metadata_path(conn, :index))
  end
end
