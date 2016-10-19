defmodule Bookish.TaggingTest do
  use Bookish.ConnCase

  import Bookish.Tagging
  alias Bookish.Tag
  alias Bookish.Book

  test "list_from_string returns a list of tags from a comma-separated string" do
    assert list_from_string("one, two, three") == ["one", "two", "three"]
    assert list_from_string("one,two,three") == ["one", "two", "three"]
  end

  test "get_or_create_tag returns an existing record if a tag exists with the same text" do
    Repo.insert! %Tag{text: "elixir"}
    
    assert get_or_create_tag(["elixir"]) == [Repo.get_by(Tag, text: "elixir")] 
    assert length(Repo.all(Tag)) == 1
  end

  test "get_or_create_tag returns a new record if a tag does not already exist" do
    get_or_create_tag(["ruby"])
    assert length(Repo.all(Tag)) == 1
  end

  test "tags are case insensitive" do
    get_or_create_tag(["ruby"])
    get_or_create_tag(["Ruby"])
    get_or_create_tag(["RUBY"])
    
    assert length(Repo.all(Tag)) == 1
  end

  test "get or create tag returns a collection of existing and new records" do
    Repo.insert! %Tag{text: "elixir"}
    get_or_create_tag(["elixir", "ruby"])
    assert length(Repo.all(Tag)) == 2
  end

  test "associate_with_resource takes a list of tags and associates each one with the given resource" do
    book = Repo.insert! %Book{}
    get_or_create_tag(["elixir", "ruby"])
    |> associate_with_resource(book)

    assert(book |> Repo.preload(:tags) |> has_tags(2))
  end

  test "update_tags takes a list of tags and adds each one to the database for the given book" do
    book = Repo.insert! %Book{}
    update_tags(book, "ruby, elixir, testing")

    assert(book |> Repo.preload(:tags) |> has_tags(3))
  end

  defp has_tags(book, count) do
    length(book.tags) == count 
  end
end
