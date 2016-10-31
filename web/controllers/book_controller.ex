defmodule Bookish.BookController do
  use Bookish.Web, :controller
  
  plug Bookish.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  alias Bookish.Book
  alias Bookish.Resource
  alias Bookish.Tagging
  alias Bookish.Location
  alias Bookish.PaginationController

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
      |> preload_associations
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
    books = 
      Resource.get_checked_out(Book) 
      |> Repo.all
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
    |> Repo.preload(:tags)
    |> Repo.preload(:location)
  end
  
  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  def set_attributes(resource) do
    if Resource.checked_out?(resource) do 
      set_checked_out_attributes(resource)
    else
      resource
    end
  end

  defp set_checked_out_attributes(resource) do
    changeset = 
      resource
      |> Resource.checkout(%{"checked_out": true, "borrower_name": Resource.borrower_name(resource)})
    case Repo.update(changeset) do
      {:ok, resource} ->
        resource
    end
  end
end
