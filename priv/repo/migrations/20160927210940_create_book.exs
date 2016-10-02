defmodule Bookish.Repo.Migrations.CreateBook do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :author_firstname, :string
      add :author_lastname, :string
      add :year, :integer
      add :current_location, :string

      timestamps()
    end

  end
end
