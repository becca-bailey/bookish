defmodule Bookish.Book do
  use Bookish.Web, :model

  schema "books" do
    field :title, :string
    field :author_firstname, :string
    field :author_lastname, :string
    field :year, :integer
    field :current_location, :string
    field :checked_out, :boolean, default: false
    field :checked_out_to, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :author_firstname, :author_lastname, :year, :current_location])
    |> validate_required([:title, :author_firstname, :author_lastname, :year])
    |> validate_number(:year, greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, message: "Must be a valid year")
  end

  def checkout(struct, params \\ %{}) do
    struct
    |> cast(params, [:checked_out, :checked_out_to, :current_location])
    |> validate_required([:checked_out, :checked_out_to])
    |> validate_acceptance(:checked_out)
    |> validate_inclusion(:current_location, ["", nil])
  end

  def return(struct, params \\ %{}) do
    struct 
    |> cast(params, [:checked_out, :checked_out_to, :current_location])
    |> validate_required([:checked_out, :current_location])
    |> validate_inclusion(:checked_out, [false])
    |> validate_inclusion(:checked_out_to, ["", nil])
  end
end
