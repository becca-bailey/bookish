defmodule Bookish.TagControllerTest do
  use Bookish.ConnCase

  alias Bookish.Tag
  alias Bookish.BookMetadata

  @valid_attrs %{text: "some content"}
  @invalid_attrs %{}

  test "a tag can be added to book metadata" do
    metadata = Repo.insert! %BookMetadata{} 
    tag = Repo.insert! %Tag{text: "great!"} 
 
    metadata
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!
 
    assert metadata |> Repo.preload(:tags) |> has_tags
  end
 
  test "a collection of tags can be added to metadata" do
    metadata = Repo.insert! %BookMetadata{} 
    tag1 = Repo.insert! %Tag{text: "elixir"} 
    tag2 = Repo.insert! %Tag{text: "testing"} 
 
    metadata 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag1, tag2])
    |> Repo.update!
 
    assert metadata |> Repo.preload(:tags) |> has_tags(2) 
  end

  test "a collection of metadata can be queried by a tag" do
    poodr = Repo.insert!(%BookMetadata{title: "Practical Object-Oriented Design in Ruby"})
    wgr = Repo.insert!(%BookMetadata{title: "The Well-Grounded Rubyist"})
 
    tag = Repo.insert!(%Tag{text: "ruby"})
 
    Enum.each([poodr, wgr], fn(book) ->
      book
      |> Repo.preload(:tags)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:tags, [tag])
      |> Repo.update!
    end)
 
    assert tag |> Repo.preload(:book_metadata) |> has_books(2)
  end

  test "when tagged metadata is deleted, the tag still exists", %{conn: conn} do
    metadata = Repo.insert!(%BookMetadata{})
    tag = Repo.insert!(%Tag{})
 
    metadata 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!
 
    assert(tag |> Repo.preload(:book_metadata) |> has_books)
 
    conn
    |> assign(:current_user, %{id: 1, name: "user"})
    |> delete(book_metadata_path(conn, :delete, metadata))
 
    assert tag
    refute tag |> Repo.preload(:book_metadata) |> has_books
  end

  test "the tag show route shows a list of books with that tag", %{conn: conn} do
    book_metadata = Repo.insert!(%BookMetadata{title: "Tagged book"})
    tag = Repo.insert!(%Tag{text: "tag"})
    
    book_metadata 
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, [tag])
    |> Repo.update!

    conn = get conn, tag_path(conn, :show, tag)

    assert html_response(conn, 200) =~ "Tagged book" 
  end

  defp has_tags(metadata) do
    length(metadata.tags) > 0
  end
  
  defp has_tags(metadata, count) do
    length(metadata.tags) == count
  end
  
  defp has_books(tag) do
    length(tag.book_metadata) > 0
  end
  
  defp has_books(tag, count) do
    length(tag.book_metadata) == count
  end
end
