defmodule Bookish.BookViewTest do
  use Bookish.ConnCase, async: true
  alias Bookish.BookView

  # Bring render/3 and render_to_string/3 for testing custom views
  # import Phoenix.View

  test "to_string converts a character to a string" do
    assert BookView.char_to_string(97) == "A"
  end
end
