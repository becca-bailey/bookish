defmodule Bookish.Plugs.AssignBook do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do
    case conn.params do
      %{"book_id" => book_id} ->
        book = Bookish.Repo.get(Bookish.Book, book_id)
        assign(conn, :book, book)
      {:ok, _book} ->
        conn
    end
  end
end
