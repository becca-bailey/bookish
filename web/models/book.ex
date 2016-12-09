defmodule Bookish.Book do
  use Bookish.Web, :model

  schema "books" do
    field :title, :string, virtual: true
    field :author_firstname, :string, virtual: true
    field :author_lastname, :string, virtual: true
    field :year, :integer, virtual: true
    field :current_location, :string
    field :checked_out, :boolean, virtual: true, default: false
    field :borrower_name, :string, virtual: true
    field :tags_list, :string, virtual: true

    belongs_to :book_metadata, Bookish.BookMetadata
    has_many :check_outs, Bookish.CheckOut
    belongs_to :location, Bookish.Location

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :author_firstname, :author_lastname, :year, :current_location, :tags_list, :location_id])
    |> validate_required([:title, :author_firstname, :author_lastname, :year])
    |> validate_number(:year, greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, message: "Must be a valid year")
  end
  
  def with_existing_metadata(struct, params \\ %{}) do
    struct
    |> cast(params, [:current_location, :location_id])
    |> validate_required([:current_location, :location_id])
  end
end
