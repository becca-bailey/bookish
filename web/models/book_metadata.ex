defmodule Bookish.BookMetadata do
  use Bookish.Web, :model

  schema "book_metadata" do
    field :title, :string
    field :author_firstname, :string
    field :author_lastname, :string
    field :year, :integer
    field :tags_list, :string, virtual: true
    many_to_many :tags, Bookish.Tag, join_through: Bookish.BookMetadataTags, on_delete: :delete_all, on_replace: :delete

    has_many :books, Bookish.Book, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :author_firstname, :author_lastname, :year, :tags_list])
    |> validate_required([:title, :author_firstname, :author_lastname, :year])
    |> validate_number(:year, greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, message: "Must be a valid year")
  end

  def add_tags(struct, params \\ %{}) do
    struct
    |> cast(params, [:tags_list])
  end

  # Queries

  def sorted_by_title do
    from m in Bookish.BookMetadata,
      order_by: m.title,
      select: m
  end
end
