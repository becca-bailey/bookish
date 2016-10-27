defmodule Bookish.Circulation do
  use Bookish.Web, :controller
  import Ecto.Query
  import Bookish.CirculationHelpers

  plug Bookish.Plugs.RequireAuth when action in [:check_out, :return, :process_return]

  alias Bookish.Book
  alias Bookish.CheckOut
  alias Bookish.AuthController, as: Auth
 

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
    current_user = Auth.get_user(conn)
    try_return(conn, current_user.id, borrower_id(book), book)
  end

  defp try_return(conn, current_user_id, borrower_id, book) when current_user_id == borrower_id do
    changeset = Book.return(%Book{})
    render(conn, "return.html", book: book, changeset: changeset) 
  end

  defp try_return(conn, _, _, _) do
    conn
    |> put_flash(:error, "You cannot return someone else's book!")
    |> redirect(to: book_path(conn, :index))
  end

  def borrower_name(book) do
    if checked_out?(book) do
      record = get_first_record(book.id)
      record.borrower_name
    end
  end

  def borrower_id(book) do
    if checked_out?(book) do
      record = get_first_record(book.id)
      record.borrower_id
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

  def checked_out?(book_id) when is_integer(book_id) do
    current_record_exists(book_id)
  end
  
  def checked_out?(book) do
    current_record_exists(book.id)
  end

  defp add_return_date(book) do
    date = 
      DateTime.utc_now()
      |> DateTime.to_date 
      
    changeset = 
      get_first_record(book.id)
      |> CheckOut.return(%{"return_date": date})

    Repo.update(changeset)
  end

  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  def set_attributes(book) do
    if checked_out?(book) do 
      set_checked_out_attributes(book)
    else
      book
    end
  end

  defp set_checked_out_attributes(book) do
    changeset = 
      book
      |> Book.checkout(%{"checked_out": true, "borrower_name": borrower_name(book)})
    case Repo.update(changeset) do
      {:ok, book} ->
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
