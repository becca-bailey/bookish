defmodule Bookish.ResourceController do
  use Bookish.Web, :controller

  alias Bookish.Resource
  alias Bookish.CheckOut
  alias Bookish.AuthController, as: Auth
  
  @entries_per_page 10 

  def checked_out(conn, query) do
    resources = 
      Resource.get_checked_out(query) 
      |> Repo.all
      |> set_virtual_attributes
    render(conn, "checked_out.html", books: resources)
  end

  def paginate(conn, %{"number" => number}, model) do
    n = String.to_integer(number)
    resources = 
      model
      |> Resource.sorted_by_title
      |> Resource.paginate(n, @entries_per_page)
      |> load_from_query
    render(conn, "index.html", books: resources, page_count: number_of_pages(model), current_page: n, filtered: false)
  end
  
  def index_by_letter(conn, %{"letter" => letter}, model) do
    resources =
      model
      |> Resource.get_by_letter(letter)
      |> load_from_query 
    render(conn, "index.html", books: resources, page_count: number_of_pages(model), current_page: 1, filtered: true)
  end

  defp number_of_pages(model) do
    count = 
      model 
      |> Resource.count
      |> Repo.all
      |> List.first
    Float.ceil(count / @entries_per_page)
    |> Kernel.trunc
  end

  defp load_from_query(query) do
    query
    |> Repo.all
    |> preload_associations
    |> set_virtual_attributes 
  end

  def preload_associations(coll) do
    coll
    |> Repo.preload(:tags)
    |> Repo.preload(:location)
  end
  
  def return(conn, resource) do
    current_user = Auth.get_user(conn)

    try_return(conn, current_user.id, Resource.borrower_id(resource), resource)
  end

  defp try_return(conn, current_user_id, borrower_id, book) when current_user_id == borrower_id do
    changeset = Resource.return(%Bookish.Book{})
    render(conn, "return.html", book: book, changeset: changeset) 
  end

  defp try_return(conn, _, _, _) do
    conn
    |> put_flash(:error, "You cannot return someone else's book!")
    |> redirect(to: book_path(conn, :index))
  end

  def process_return(conn, resource, params) do
    changeset = Resource.return(resource, params)

    case Repo.update(changeset) do
      {:ok, resource} ->
        add_return_date(resource)
        conn
        |> put_flash(:info, "Book has been returned!")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "return.html", book: resource, changeset: changeset)
    end
  end

  def add_return_date(book) do
    date = 
      DateTime.utc_now()
      |> DateTime.to_date 
      
    changeset = 
      Resource.get_first_record(book.id)
      |> CheckOut.return(%{"return_date": date})

    Repo.update(changeset)
  end

  
  def update_resource_with_location(resource) do
    changeset = 
      resource
      |> Resource.checkout(%{"current_location": ""})
      
    case Repo.update (changeset) do
      {:ok, resource} ->
        resource
    end
  end

  def set_virtual_attributes(coll) do
    coll 
    |> Enum.map(&(set_attributes(&1)))
  end

  def set_attributes(resource) do
    if Resource.checked_out?(resource) do 
      set_checked_out_attributes(resource)
    else
      resource
    end
  end

  defp set_checked_out_attributes(resource) do
    changeset = 
      resource
      |> Resource.checkout(%{"checked_out": true, "borrower_name": Resource.borrower_name(resource)})
    case Repo.update(changeset) do
      {:ok, resource} ->
        resource
    end
  end
end
