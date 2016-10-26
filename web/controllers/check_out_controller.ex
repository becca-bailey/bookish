defmodule Bookish.CheckOutController do
  use Bookish.Web, :controller
  
  plug :assign_book
  plug Bookish.Plugs.RequireAuth when action in [:new, :create]

  alias Bookish.CheckOut
  alias Bookish.Circulation

  def index(conn, _params) do
    check_outs = Repo.all(CheckOut)
    render(conn, "index.html", check_outs: check_outs)
  end

  def create(conn, data) do
    user = get_user(conn)
    check_out_params = Map.merge(data, %{"borrower_name" => user.name, "borrower_id" => user.id})
    changeset = 
      conn
      |> Circulation.get_book_with_location
      |> build_assoc(:check_outs)
      |> CheckOut.changeset(check_out_params)

    case Repo.insert(changeset) do
      {:ok, _check_out} ->
        conn
        |> put_flash(:info, "Book has been checked out!")
        |> redirect(to: book_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Book cannot be checked out")
        |> redirect(to: book_path(conn, :index))
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

  defp get_user(conn) do
    get_session(conn, :current_user) || conn.assigns[:current_user]
  end

end
