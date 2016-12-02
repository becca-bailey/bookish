defmodule Bookish.Repo.Migrations.CreateBookMetadata do
  use Ecto.Migration

  def change do
    create table(:book_metadata) do
      add :title, :string
      add :author_firstname, :string
      add :author_lastname, :string
      add :year, :integer

      timestamps()
    end
  end
end
