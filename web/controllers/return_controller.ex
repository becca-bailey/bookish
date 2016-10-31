defmodule Bookish.ReturnController do
  use Bookish.Web, :controller

  alias Bookish.Book
  alias Bookish.Resource
  alias Bookish.CheckOut
  alias Bookish.AuthController, as: Auth


  plug Bookish.Plugs.RequireAuth when action in [:process_return]
  plug Bookish.Plugs.AssignBook

  def return(conn, %{"book_id" => id}) do
    resource = Repo.get!(Book, id)
    current_user = Auth.get_user(conn)

    try_return(conn, current_user.id, Resource.borrower_id(resource), resource)
  end

  def process_return(conn, %{"book_id" => id, "book" => book_params}) do
    resource = Repo.get!(Book, id)
    changeset = Resource.return(resource, book_params)

    case Repo.update(changeset) do
      {:ok, resource} ->
        add_return_date(resource)
        conn
        |> put_flash(:info, "Book has been returned!")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "return.html", book: resource, changeset: changeset)
    end
  end
  
  defp try_return(conn, current_user_id, borrower_id, book) when current_user_id == borrower_id do
    changeset = Resource.return(%Bookish.Book{})
    render(conn, "return.html", book: book, changeset: changeset) 
  end

  defp try_return(conn, _, _, _) do conn
    |> put_flash(:error, "You cannot return someone else's book!")
    |> redirect(to: book_path(conn, :index))
  end
  
  defp add_return_date(book) do
    date = 
      DateTime.utc_now()
      |> DateTime.to_date 
      
    changeset = 
      Resource.get_first_record(book.id)
      |> CheckOut.return(%{"return_date": date})

    Repo.update(changeset)
  end
  
end
