defmodule Bookish.Book do
  use Bookish.Web, :model

  alias Bookish.CheckOut
  alias Bookish.Repo

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
  
  def checkout(struct, params \\ %{}) do
    struct
    |> cast(params, [:borrower_name, :checked_out, :current_location])
    |> validate_inclusion(:current_location, ["", nil])
  end
  
  def return(struct, params \\ %{}) do
    struct 
    |> cast(params, [:current_location])
    |> validate_required([:current_location])
  end

  def set_virtual_attributes(struct, params \\ %{}) do
    struct
    |> cast(params, [:checked_out, :borrower_name, :title, :author_firstname, :author_lastname, :year])
  end

  def set_checked_out(struct, params \\ %{}) do
    struct 
    |> cast(params, [:checked_out, :borrower_name])
  end

  # Helpers 
  
  def checked_out?(book_id) when is_integer(book_id) do
    current_record_exists(book_id)
  end
  
  def checked_out?(book) do
    current_record_exists(book.id)
  end

  def borrower_name(book) do
    if checked_out?(book) do
      record = get_first_record(book.id)
      record.borrower_name
    end
  end

  def borrower_id(book) do
    if checked_out?(book) do
      record = get_first_record(book.id)
      record.borrower_id
    end
  end

  defp get_current_records(book_id) do
    CheckOut.current(CheckOut, book_id) |> Repo.all
  end

  def get_first_record(book_id) do
    get_current_records(book_id)
    |> List.first      
  end

  def current_record_exists(book_id) do
    get_current_records(book_id)
    |> not_empty?
  end

  defp not_empty?(coll) do
    List.first(coll) != nil
  end

  # Queries

  def sorted_by_title(query) do
    from r in query,
      order_by: r.title,
      select: r
  end
  
  def get_by_letter(query, letter) do
    from r in query,
      where: ilike(r.title, ^"#{letter}%"),
      order_by: r.title,
      select: r
  end

  def paginate(query, page, size) do
    from b in query,
      limit: ^size,
      offset: ^((page-1) * size)
  end

  def count(query) do
    from b in query,
      select: count(b.id)
  end

  def get_checked_out(query) do
    from b in query,
      join: c in CheckOut, on: c.book_id == b.id,
      where: is_nil(c.return_date),
      select: b
  end

  def get_checked_out(query, borrower_id) do
    from b in query,
      join: c in CheckOut, on: c.book_id == b.id,
      where: is_nil(c.return_date) and c.borrower_id == ^borrower_id,
      select: b
  end
end
