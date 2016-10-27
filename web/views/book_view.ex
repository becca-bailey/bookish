defmodule Bookish.BookView do
  use Bookish.Web, :view
  import Bookish.ViewHelpers

  def char_to_string(char) do
    String.upcase(List.to_string([char]))
  end
end
