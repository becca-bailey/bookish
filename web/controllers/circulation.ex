defmodule Bookish.Circulation do
  use Bookish.Web, :controller

  alias Bookish.Book
  alias Bookish.CheckOut

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

  def check_out(conn) do
    changeset = 
      conn.assigns[:book]
      |> Repo.preload([:check_outs])
      |> Book.checkout(%{"current_location": ""})
    case Repo.update (changeset) do
      {:ok, book} ->
        book
    end
  end

  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  defp set_attributes(book) do
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
end
