defmodule Bookish.TagView do
  use Bookish.Web, :view
  
  def get_class_name(book) do
    if book.checked_out do
      "checked-out"
    else
      "available"
    end
  end
end
