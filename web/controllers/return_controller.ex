defmodule Bookish.ReturnController do
  use Bookish.Web, :controller

  alias Bookish.Book
  alias Bookish.CheckOut
  alias Bookish.AuthController, as: Auth


  plug Bookish.Plugs.RequireAuth when action in [:process_return]
  plug Bookish.Plugs.AssignBook

  def return(conn, %{"book_id" => id}) do
    book = Repo.get!(Book, id)
    current_user = Auth.get_user(conn)

    try_return(conn, current_user.id, Book.borrower_id(book), book)
  end

  def process_return(conn, %{"book_id" => id, "book" => book_params}) do
    book = Repo.get!(Book, id)
    changeset = Book.return(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        add_return_date(book)
        conn
        |> put_flash(:info, "Book has been returned!")
        |> redirect(to: book_metadata_path(conn, :index))
      {:error, changeset} ->
        render(conn, "return.html", book: book, changeset: changeset)
    end
  end
  
  defp try_return(conn, current_user_id, borrower_id, book) when current_user_id == borrower_id do
    changeset = Book.return(%Bookish.Book{})
    render(conn, "return.html", book: book, changeset: changeset) 
  end

  defp try_return(conn, _, _, _) do conn
    |> put_flash(:error, "You cannot return someone else's book!")
    |> redirect(to: book_metadata_path(conn, :index))
  end
  
  defp add_return_date(book) do
    date = 
      DateTime.utc_now()
      |> DateTime.to_date 
      
    changeset = 
      Book.get_first_record(book.id)
      |> CheckOut.return(%{"return_date": date})

    Repo.update(changeset)
  end
  
end
