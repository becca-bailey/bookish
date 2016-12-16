defmodule Bookish.CheckOutController do
  use Bookish.Web, :controller

  plug :assign_book
  plug Bookish.Plugs.RequireAuth when action in [:new, :create]

  alias Bookish.CheckOut
  alias Bookish.Book
  alias Bookish.AuthController, as: Auth
  alias Bookish.Repository

  def index(conn, _params) do
    check_outs = Repo.all(CheckOut)
    render(conn, "index.html", check_outs: check_outs)
  end

  def create(conn, data) do
    user = Auth.get_user(conn)
    check_out_params = Map.merge(data, %{"borrower_name" => user.name, "borrower_id" => user.id})
    changeset =
      conn
      |> clear_location_details
      |> build_assoc(:check_outs)
      |> CheckOut.changeset(check_out_params)

    case Repo.insert(changeset) do
      {:ok, check_out} ->
        metadata = Repository.get_associated_metadata_for_check_out(check_out |> Repo.preload(:book))
        conn
        |> put_flash(:info, "Book has been checked out!")
        |> redirect(to: book_metadata_path(conn, :show, metadata))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Book cannot be checked out")
        |> redirect(to: book_metadata_path(conn, :index))
    end
  end

  def clear_location_details(conn) do
    resource = conn.assigns[:book]
    changeset =
      resource
      |> Book.checkout(%{"current_location": ""})

    case Repo.update (changeset) do
      {:ok, resource} ->
        resource
    end
  end

  defp assign_book(conn, _opts) do
    case conn.params do
      %{"book_id" => book_id} ->
        assign(conn, :book, Repository.get_book(book_id))
      {:ok, _book} ->
        conn
    end
  end
end
