defmodule Bookish.BookMetadataTags do
  use Bookish.Web, :model

  schema "book_metadata_tags" do
    belongs_to :book_metadata, Bookish.BookMetadata
    belongs_to :tag, Bookish.Tag

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:book_metadata_id, :tag_id])
    |> validate_required([:book_metadata_id, :tag_id])
  end
end
