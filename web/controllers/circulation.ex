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

  def get_book_with_location(conn) do
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
    current_user = get_current_user(conn)
    if current_user.id == borrower_id(book) do
      changeset = Book.return(%Book{})
      render(conn, "return.html", book: book, changeset: changeset) 
    else
      conn
      |> put_flash(:error, "You cannot return someone else's book!")
      |> redirect(to: book_path(conn, :index))
    end
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

  def borrower_name(book) do
    if checked_out?(book) do
      record = List.first(CheckOut.current(CheckOut, book.id) |> Repo.all)
      record.borrower_name
    end
  end

  def borrower_id(book) do
    if checked_out?(book) do
      record = List.first(CheckOut.current(CheckOut, book.id) |> Repo.all)
      record.borrower_id
    end
  end

  defp not_empty?(coll) do
    List.first(coll) != nil
  end

  defp get_current_user(conn) do
    get_session(conn, :current_user) || conn.assigns[:current_user]
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
        |> Book.checkout(%{"checked_out": true, "borrower_name": borrower_name(book)})
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
