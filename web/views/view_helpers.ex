defmodule Bookish.ViewHelpers do
  def get_class_name(book) do
    if book.checked_out do
      "checked-out"
    else
      "available"
    end
  end

  def get_number_class(n, current_page) when n == current_page do
    "disabled"
  end

  def get_number_class(_, _) do
    "enabled"
  end
  
  def char_to_string(char) do
    [char]
    |> List.to_string
    |> String.upcase
  end

  def empty?(books) do
    length(books) == 0
  end
  
  def number_of_copies(book_metadata) do
    n = length(book_metadata.books)
    if n == 1 do
      "1 copy"
    else
      "#{n} copies"
    end
  end
end


