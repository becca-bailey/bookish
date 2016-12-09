defmodule Bookish.Repo.Migrations.CreateBookMetadataTags do
  use Ecto.Migration

  def change do
    create table(:book_metadata_tags) do
      add :book_metadata_id, :integer
      add :tag_id, :integer

      timestamps()
    end

  end
end
