defmodule Bookish.CheckOutController do
  use Bookish.Web, :controller
  
  plug :assign_book

  alias Bookish.CheckOut
  alias Bookish.Circulation

  def index(conn, _params) do
    check_outs = Repo.all(CheckOut)
    render(conn, "index.html", check_outs: check_outs)
  end

  def new(conn, _params) do
    book = conn.assigns[:book]
    if Circulation.checked_out? book do
      conn
      |> put_flash(:error, "Book is already checked out!")
      |> redirect(to: book_path(conn, :index))
    else
      changeset = CheckOut.changeset(%CheckOut{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"check_out" => check_out_params}) do
    changeset = 
      conn
      |> Circulation.check_out 
      |> build_assoc(:check_outs)
      |> CheckOut.changeset(check_out_params)

    case Repo.insert(changeset) do
      {:ok, _check_out} ->
        conn
        |> put_flash(:info, "Book has been checked out!")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp assign_book(conn, _opts) do
    case conn.params do
      %{"book_id" => book_id} ->
        book = Repo.get(Bookish.Book, book_id)
        assign(conn, :book, book)
      {:ok, _book} ->
        conn
    end
  end
end
