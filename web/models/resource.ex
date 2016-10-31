defmodule Bookish.Resource do
  use Bookish.Web, :model
  import Ecto.Query

  alias Bookish.CheckOut
  alias Bookish.Repo

  # Changesets
  
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

  def add_tags(struct, params \\ %{}) do
    struct
    |> cast(params, [:tags_list])
  end

  # Helpers 
  
  def checked_out?(resource_id) when is_integer(resource_id) do
    current_record_exists(resource_id)
  end
  
  def checked_out?(resource) do
    current_record_exists(resource.id)
  end

  def borrower_name(resource) do
    if checked_out?(resource) do
      record = get_first_record(resource.id)
      record.borrower_name
    end
  end

  def borrower_id(book) do
    if checked_out?(book) do
      record = get_first_record(book.id)
      record.borrower_id
    end
  end

  defp get_current_records(resource_id) do
    CheckOut.current(CheckOut, resource_id) |> Repo.all
  end

  def get_first_record(resource_id) do
    get_current_records(resource_id)
    |> List.first      
  end

  def current_record_exists(resource_id) do
    get_current_records(resource_id)
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
end
