defmodule Bookish.TagController do
  use Bookish.Web, :controller

  alias Bookish.Tag

  def create(conn, %{"tag" => tag_params}) do
    changeset = Tag.changeset(%Tag{}, tag_params)

    case Repo.insert(changeset) do
      {:ok, _tag} ->
        conn
        |> put_flash(:info, "Tag created successfully.")
        |> redirect(to: tag_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag = Repo.get!(Tag, id) |> Repo.preload(:books) 
    books = tag.books |> Repo.preload(:tags)
    render(conn, "show.html", tag: tag, books: books)
  end

  def delete(conn, %{"id" => id}) do
    tag = Repo.get!(Tag, id)

    Repo.delete!(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: tag_path(conn, :index))
  end
end
