defmodule Bookish.BookView do
  use Bookish.Web, :view

  def get_class_name(book) do
    if book.checked_out do
      "checked-out"
    else
      "available"
    end
  end

  def char_to_string(char) do
    String.upcase(List.to_string([char]))
  end
end
