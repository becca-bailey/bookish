defmodule Bookish.BookMetadataController do
  use Bookish.Web, :controller
  alias Bookish.BookMetadata

  def build_from_book(book) do
    params = %{"title" => book.title, "author_firstname" => book.author_firstname, "author_lastname" => book.author_lastname, "year" => book.year }
    changeset = BookMetadata.changeset(%BookMetadata{}, params) 
    case Repo.insert!(changeset) do
      metadata ->
        metadata
    end
  end
end
