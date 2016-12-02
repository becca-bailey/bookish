defmodule Bookish.BookMetadata do
  use Bookish.Web, :model

  schema "book_metadata" do
    field :title, :string
    field :author_firstname, :string
    field :author_lastname, :string
    field :year, :integer

    has_many :books, Bookish.Book

    timestamps()
  end

  # Changesets
  
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :author_firstname, :author_lastname, :year])
    |> validate_required([:title, :author_firstname, :author_lastname, :year])
    |> validate_number(:year, greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, message: "Must be a valid year")
  end
end
