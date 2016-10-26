defmodule Bookish.TagControllerTest do
  use Bookish.ConnCase

  alias Bookish.Tag
  alias Bookish.Book

  @valid_attrs %{text: "some content"}
  @invalid_attrs %{}

  test "a tag can be added to a book" do
    book = Repo.insert!(%Book{})
    tag = Repo.insert!(%Tag{text: "great!"})

    book
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!

    assert book |> Repo.preload(:tags) |> has_tags
  end

  test "a collection of tags can be added to a book" do
    book = Repo.insert!(%Book{})
    tag1 = Repo.insert!(%Tag{text: "elixir"})
    tag2 = Repo.insert!(%Tag{text: "testing"})

    book 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag1, tag2])
    |> Repo.update!

    assert book |> Repo.preload(:tags) |> has_tags(2) 
  end

  test "a collection of books can be queried by a tag" do
    poodr = Repo.insert!(%Book{title: "Practical Object-Oriented Design in Ruby"})
    wgr = Repo.insert!(%Book{title: "The Well-Grounded Rubyist"})

    tag = Repo.insert!(%Tag{text: "ruby"})

    Enum.each([poodr, wgr], fn(book) ->
      book
      |> Repo.preload(:tags)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:tags, [tag])
      |> Repo.update!
    end)

    assert tag |> Repo.preload(:books) |> has_books(2)
  end
  
  test "when a tagged book is deleted, the tag still exists", %{conn: conn} do
    book = Repo.insert!(%Book{})
    tag = Repo.insert!(%Tag{})

    book 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!

    assert(tag |> Repo.preload(:books) |> has_books)

    conn
    |> assign(:current_user, %{id: 1, name: "user"})
    |> delete(book_path(conn, :delete, book))

    assert tag
    refute tag |> Repo.preload(:books) |> has_books
  end

  test "the tag show route shows a list of books with that tag", %{conn: conn} do
    book = Repo.insert!(%Book{title: "Tagged book"})
    tag = Repo.insert!(%Tag{text: "tag"})
    
    book 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!

    conn = get conn, books_tag_path(conn, :show, tag)

    assert html_response(conn, 200) =~ "Tagged book" 
  end

  defp has_tags(book) do
    length(book.tags) > 0
  end
  
  defp has_tags(book, count) do
    length(book.tags) == count
  end
  
  defp has_books(tag) do
    length(tag.books) > 0
  end
  
  defp has_books(tag, count) do
    length(tag.books) == count
  end
end
