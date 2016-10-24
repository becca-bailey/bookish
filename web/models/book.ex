defmodule Bookish.Book do
  use Bookish.Web, :model
  import Ecto.Query

  schema "books" do
    field :title, :string
    field :author_firstname, :string
    field :author_lastname, :string
    field :year, :integer
    field :current_location, :string
    field :checked_out, :boolean, virtual: true, default: false
    field :checked_out_to, :string, virtual: true
    field :tags_list, :string, virtual: true

    has_many :check_outs, Bookish.CheckOut
    many_to_many :tags, Bookish.Tag, join_through: Bookish.BookTag, on_delete: :delete_all, on_replace: :delete
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

  def checkout(struct, params \\ %{}) do
    struct
    |> cast(params, [:checked_out_to, :checked_out, :current_location])
    |> validate_inclusion(:current_location, ["", nil])
  end

  def return(struct, params \\ %{}) do
    struct 
    |> cast(params, [:current_location])
    |> validate_required([:current_location])
  end

  def tags(struct, params \\ %{}) do
    struct
    |> cast(params, [:tags_list])
  end
  
  def sorted_by_title do
    from b in Bookish.Book,
    order_by: b.title,
    select: b
  end

  def get_by_letter(letter) do
    from b in Bookish.Book,
    where: ilike(b.title, ^"#{letter}%"),
    select: b
  end
end
