defmodule Bookish.Tagging do
  use Bookish.Web, :controller
  alias Bookish.Tag
  alias Bookish.BookMetadata

  def update_tags(book, tags_string) do
    list_from_string(tags_string)
    |> get_or_create_tag
    |> associate_with_resource(book)
  end

  def list_from_string(tags_string) when is_nil(tags_string) do
    []
  end

  def list_from_string(tags_string) do
    String.split(tags_string, ",")
    |> Enum.map(&(String.trim &1))
  end

  def get_or_create_tag(tags_list) do
    tags_list
    |> Enum.map(&(create_or_find_by_text String.downcase(&1)))
  end

  defp create_or_find_by_text(text) do
    try do
      Repo.get_by!(Tag, text: text)
    rescue
      Ecto.NoResultsError ->
        add_tag(text)
    end
  end

  defp add_tag(text) do
    case Repo.insert %Tag{text: text} do
      {:ok, tag} -> tag
    end
  end

  def associate_with_resource(tag_entries, book_metadata) do
    book_metadata
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tag_entries)
    |> Repo.update!
  end

  def set_tags_list(book) do
    tags_list = tags_to_string book.tags
    changeset =
      book
      |> BookMetadata.add_tags(%{"tags_list": tags_list})

    case Repo.update(changeset) do
      {:ok, book} ->
        book
    end
  end

  defp tags_to_string(tags) do
    tags
    |> Enum.map(&(&1.text))
    |> Enum.join(", ")
  end
end
