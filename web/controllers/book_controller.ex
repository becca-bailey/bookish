defmodule Bookish.BookController do
  use Bookish.Web, :controller
  
  plug Bookish.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  alias Bookish.Book
  alias Bookish.Tagging
  alias Bookish.Location
  alias Bookish.ResourceController

  @entries_per_page 10 

  def index(conn, _params) do
    conn
    |> redirect(to: book_path(conn, :paginate, 1))
  end

  def new(conn, _params) do
    changeset = Book.changeset(%Book{}) 
    render(conn, "new.html", changeset: changeset, locations: get_locations)
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
        render(conn, "new.html", changeset: changeset, locations: get_locations)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = 
      Repo.get!(Book, id) 
      |> ResourceController.preload_associations
      |> Tagging.set_tags_list
    changeset = Book.changeset(book)
    render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = 
      Repo.get!(Book, id) 
      |> Repo.preload(:location)
    changeset = Book.changeset(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        Tagging.update_tags(book, book.tags_list)
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset, locations: get_locations)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    Repo.delete!(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: book_path(conn, :index))
  end
  
  def checked_out(conn, _params) do
    ResourceController.checked_out(conn, Book)
  end

  def paginate(conn, params) do
    ResourceController.paginate(conn, params, Book)
  end

  def index_by_letter(conn, params) do
    ResourceController.index_by_letter(conn, params, Book)
  end

  def return(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    ResourceController.return(conn, book)
  end
  
  def process_return(conn, %{"id" => id, "book" => book_params}) do
    book = Repo.get!(Book, id)
    ResourceController.process_return(conn, book, book_params)
  end

  def update_with_location(conn) do
    ResourceController.update_resource_with_location(conn.assigns[:book])
  end

  defp get_locations do
    Location.select_name 
    |> Repo.all
  end
end
