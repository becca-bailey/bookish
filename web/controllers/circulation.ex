defmodule Bookish.Circulation do
  use Bookish.Web, :controller
  import Ecto.Query

  plug Bookish.Plugs.RequireAuth when action in [:check_out, :return, :process_return]

  alias Bookish.Book
  alias Bookish.CheckOut

  def checked_out(conn, _params) do
    books = 
      get_checked_out(Book) 
      |> Repo.all
      |> set_virtual_attributes
    render(conn, "checked_out.html", books: books)
  end

  def check_out(conn) do
    changeset = 
      conn.assigns[:book]
      |> Book.checkout(%{"current_location": ""})
      
    case Repo.update (changeset) do
      {:ok, book} ->
        book
    end
  end

  def return(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    changeset = Book.return(%Book{})
    render(conn, "return.html", book: book, changeset: changeset) 
  end
  
  def process_return(conn, %{"id" => id, "book" => book_params}) do
    book = Repo.get!(Book, id)
    changeset = Book.return(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        add_return_date(book)
        conn
        |> put_flash(:info, "Book has been returned!")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "return.html", book: book, changeset: changeset)
    end
  end

  def checked_out?(book) do
    not_empty?(CheckOut.current(CheckOut, book.id) |> Repo.all)
  end

  def id_checked_out?(book_id) do
    not_empty?(CheckOut.current(CheckOut, book_id) |> Repo.all)
  end

  def checked_out_to(book) do
    if checked_out?(book) do
      record = List.first(CheckOut.current(CheckOut, book.id) |> Repo.all)
      record.checked_out_to
    end
  end

  defp not_empty?(coll) do
    List.first(coll) != nil
  end

  defp add_return_date(book) do
    date = 
      DateTime.utc_now()
      |> DateTime.to_date 
      
    changeset = 
      CheckOut.current(CheckOut, book.id)
      |> Repo.all
      |> List.first
      |> CheckOut.return(%{"return_date": date})

    Repo.update(changeset)
  end


  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  def set_attributes(book) do
    if checked_out?(book) do 
      changeset = 
        book
        |> Book.checkout(%{"checked_out": true, "checked_out_to": checked_out_to(book)})
      case Repo.update(changeset) do
        {:ok, book} ->
          book
      end
    else
      book
    end
  end

  def get_checked_out(query) do
    from b in query,
      join: c in CheckOut, on: c.book_id == b.id,
      where: is_nil(c.return_date),
      select: b
  end
end
