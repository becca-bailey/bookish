defmodule Bookish.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :text, :string

      timestamps()
    end

  end
end
