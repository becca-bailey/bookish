defmodule Bookish.TagController do
  use Bookish.Web, :controller

  alias Bookish.Tag
  alias Bookish.Repository

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
    tag = Repository.get_tag(id)
    book_metadata = Repository.get_metadata_from_tag(tag)
    render(conn, "show.html", tag: tag, book_metadata: book_metadata)
  end

  def delete(conn, %{"id" => id}) do
    Repo.delete!(Repository.get_tag(id))

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: tag_path(conn, :index))
  end
end
