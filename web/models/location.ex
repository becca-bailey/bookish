defmodule Bookish.Location do
  use Bookish.Web, :model
  import Ecto.Query

  schema "locations" do
    field :name, :string
    has_many :books, Bookish.Book

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
  
  # Queries

  def select_name do
    from l in Bookish.Location,
    select: {l.name, l.id}
  end
end
