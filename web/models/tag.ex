defmodule Bookish.Tag do
  use Bookish.Web, :model

  schema "tags" do
    field :text, :string

    many_to_many :books, Bookish.Book, join_through: Bookish.BookTag 

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text])
    |> validate_required([:text])
  end
end
