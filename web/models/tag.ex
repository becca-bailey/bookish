defmodule Bookish.Tag do
  use Bookish.Web, :model

  schema "tags" do
    field :text, :string

    many_to_many :book_metadata, Bookish.BookMetadata, join_through: Bookish.BookMetadataTags 

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
