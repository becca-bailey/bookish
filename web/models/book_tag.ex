defmodule Bookish.BookTag do
  use Bookish.Web, :model

  schema "books_tags" do
    belongs_to :book, Bookish.Book
    belongs_to :tag, Bookish.Tag

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:book_id, :tag_id])
    |> validate_required([:book_id, :tag_id])
  end
end
