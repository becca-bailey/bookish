defmodule Bookish.ViewHelpers do
  def get_class_name(book) do
    if book.checked_out do
      "checked-out"
    else
      "available"
    end
  end
end


