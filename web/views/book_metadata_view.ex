defmodule Bookish.BookMetadataView do
  use Bookish.Web, :view
  import Bookish.ViewHelpers
  def number_of_copies(book_metadata) do
    n = length(book_metadata.books)
    if n == 1 do
      "1 copy"
    else
      "#{n} copies"
    end
  end
end
