defmodule Bookish.Repo.Migrations.CreateCheckOut do
  use Ecto.Migration

  def change do
    create table(:check_outs) do
      add :book_id, :integer
      add :checked_out_to, :string
      add :return_date, :date

      timestamps()
    end
  end
end
