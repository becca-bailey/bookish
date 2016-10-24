defmodule Bookish.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string

      timestamps()
    end

  end
end
