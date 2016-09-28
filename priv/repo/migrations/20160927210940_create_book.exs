defmodule Bookish.Repo.Migrations.CreateBook do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :author_firstname, :string
      add :author_lastname, :string
      add :year, :integer
      add :current_location, :string
      add :checked_out, :boolean, default: false, null: false
      add :checked_out_to, :string

      timestamps()
    end

  end
end
