defmodule Bookish.BookView do
  use Bookish.Web, :view
  import Bookish.ViewHelpers

  def char_to_string(char) do
    [char]
    |> List.to_string
    |> String.upcase
  end

  def empty?(books) do
    length(books) == 0
  end
end
