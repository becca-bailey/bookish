defmodule Bookish.ResourceTest do
  use Bookish.ConnCase

  alias Bookish.Resource
  alias Bookish.Book

  test "paginate returns the number of entries offset by the page number" do
    for _ <- 1..12 do Repo.insert!(%Book{}) end
    entries_per_page = 10
    page_1 =
      Book
      |> Resource.paginate(1, entries_per_page)
      |> Repo.all
    page_1_count = length(page_1)

    assert page_1_count == 10

    page_2 =
      Book
      |> Resource.paginate(2, entries_per_page)
      |> Repo.all
    page_2_count = length(page_2)

    assert page_2_count == 2
  end

  test "count returns the number of results in a query" do
    for _ <- 1..5 do Repo.insert!(%Book{}) end
    count =
      Book
      |> Resource.count
      |> Repo.all
      |> List.first

    assert count == 5
  end
end
