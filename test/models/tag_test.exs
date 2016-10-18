defmodule Bookish.TagTest do
  use Bookish.ModelCase

  alias Bookish.Tag

  @valid_attrs %{text: "some content"}
  @invalid_attrs %{}

  test "a tag is valid with text" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "a tag is invalid without text" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "a tag is invalid if text is an empty string" do
    changeset = Tag.changeset(%Tag{}, %{text: ""})
    refute changeset.valid?
  end
end
