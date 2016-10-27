defmodule Bookish.LocationController do
  use Bookish.Web, :controller

  alias Bookish.Location

  def index(conn, _params) do
    locations = Repo.all(Location)
    render(conn, "index.html", locations: locations)
  end

  def new(conn, _params) do
    changeset = Location.changeset(%Location{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"location" => location_params}) do
    changeset = Location.changeset(%Location{}, location_params)

    case Repo.insert(changeset) do
      {:ok, _location} ->
        conn
        |> put_flash(:info, "Location created successfully.")
        |> redirect(to: location_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    location = Repo.get!(Location, id) |> Repo.preload(:books)
    books = 
      location.books
      |> Repo.preload(:tags)
      |> Repo.preload(:location)
    render(conn, "show.html", location: location, books: books)
  end

  def edit(conn, %{"id" => id}) do
    location = Repo.get!(Location, id)
    changeset = Location.changeset(location)
    render(conn, "edit.html", location: location, changeset: changeset)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = Repo.get!(Location, id)
    changeset = Location.changeset(location, location_params)

    case Repo.update(changeset) do
      {:ok, location} ->
        conn
        |> put_flash(:info, "Location updated successfully.")
        |> redirect(to: location_path(conn, :show, location))
      {:error, changeset} ->
        render(conn, "edit.html", location: location, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = Repo.get!(Location, id)
    Repo.delete!(location)

    conn
    |> put_flash(:info, "Location deleted successfully.")
    |> redirect(to: location_path(conn, :index))
  end
end
