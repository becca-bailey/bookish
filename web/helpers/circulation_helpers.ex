defmodule Bookish.CirculationHelpers do
  alias Bookish.CheckOut
  alias Bookish.Repo
  
  defp get_current_records(book_id) do
    CheckOut.current(CheckOut, book_id) |> Repo.all
  end

  def get_first_record(book_id) do
    get_current_records(book_id)
    |> List.first      
  end

  def current_record_exists(book_id) do
    get_current_records(book_id)
    |> not_empty?
  end

  defp not_empty?(coll) do
    List.first(coll) != nil
  end
end
