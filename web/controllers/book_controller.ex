defmodule Bookish.BookController do
  use Bookish.Web, :controller

  alias Bookish.Book
  alias Bookish.Circulation
  alias Bookish.Tagging

  def index(conn, _params) do
    books = 
      Book.sorted_by_title 
      |> Repo.all
      |> Repo.preload(:tags)
      |> Circulation.set_virtual_attributes 
    render(conn, "index.html", books: books)
  end

  def index_by_letter(conn, %{"letter" => letter}) do
    books = 
      Book.get_by_letter(letter)
      |> Repo.all
      |> Repo.preload(:tags)
      |> Circulation.set_virtual_attributes
    render(conn, "index.html", books: books)
  end

  def new(conn, _params) do
    changeset = Book.changeset(%Book{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"book" => book_params}) do
    changeset = Book.changeset(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, book} ->
        Tagging.update_tags(book, book.tags_list)
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = Repo.get!(Book, id) |> Repo.preload(:tags) |> Tagging.set_tags_list
    changeset = Book.changeset(book)
    render(conn, "edit.html", book: book, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Repo.get!(Book, id)
    changeset = Book.changeset(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        Tagging.update_tags(book, book.tags_list)
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    Repo.delete!(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: book_path(conn, :index))
  end
end
