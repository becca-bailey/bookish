defmodule Bookish.Repo.Migrations.CreateBook do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :book_metadata_id, :integer
      add :location_id, :integer
      add :current_location, :string

      timestamps()
    end

  end
end
