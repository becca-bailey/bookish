defmodule Bookish.Repo.Migrations.CreateBooksTags do
  use Ecto.Migration

  def change do
    create table(:books_tags) do
      add :book_id, :integer
      add :tag_id, :integer

      timestamps()
    end

  end
end
