defmodule Bookish.BookMetadataControllerTest do
  use Bookish.ConnCase

  alias Bookish.Book
  alias Bookish.BookMetadata
  alias Bookish.Location
  alias Bookish.Tag

  @valid_attrs %{"title" => "A book", "author_firstname" => "first", "author_lastname" => "last", "year" => 2016, "location_id" => 1}
  @invalid_attrs %{}
  @user %{id: "email", name: "user"}

  test "lists all books records on index", %{conn: conn} do
    conn = get conn, book_metadata_path(conn, :index)
    assert conn.status == 200
  end

  test "creates new book metadata and redirects when data is valid", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, @user)
      |> post(book_metadata_path(conn, :create), book_metadata: @valid_attrs)

    assert redirected_to(conn) == book_metadata_path(conn, :index)
  end

  test "shows book title, author, and year on index", %{conn: conn} do
    Repo.insert! %BookMetadata{title: "title", author_firstname: "first", author_lastname: "last", year: 2016}
    conn = get conn, book_metadata_path(conn, :index)

    assert html_response(conn, 200) =~ "title"
    assert html_response(conn, 200) =~ "first last"
    assert html_response(conn, 200) =~ "2016"
  end

  test "shows the number of copies for each record", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{title: "title", author_firstname: "first", author_lastname: "last", year: 2016}
    Repo.insert! %Book{book_metadata: book_metadata}
    conn = get conn, book_metadata_path(conn, :index)

    assert html_response(conn, 200) =~ "1 copy"

    Repo.insert! %Book{book_metadata: book_metadata}
    conn = get conn, book_metadata_path(conn, :index)

    assert html_response(conn, 200) =~ "2 copies"
  end

  test "Creating a book creates associated metadata if there is no metadata_id", %{conn: conn} do
    book_params = @valid_attrs

    conn
    |> assign(:current_user, @user)
    |> post(book_path(conn, :create), book: book_params)

    book =
      Repo.all(Book)
      |> List.first
      |> Repo.preload(:book_metadata)

     data = book.book_metadata

     assert data.title == book_params["title"]
     assert data.author_firstname == book_params["author_firstname"]
     assert data.author_lastname == book_params["author_lastname"]
     assert data.year == book_params["year"]
  end

  test "Creating a book associates metadata if there is a metadata_id", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book_params = %{book_metadata_id: book_metadata.id, location_id: 1} 

    conn
    |> assign(:current_user, @user)
    |> post(book_path(conn, :create), book: book_params)

    book =
      Repo.all(Book)
      |> List.first
      |> Repo.preload(:book_metadata)

    assert book.book_metadata == book_metadata
  end

  test "Creating a book fails if it does not include valid metadata", %{conn: conn} do
    book_params = @invalid_attrs

    conn
    |> assign(:current_user, @user)
    |> post(book_path(conn, :create), book: book_params)

    refute Repo.get_by(Book, book_params)
    refute Repo.get_by(BookMetadata, book_params)
  end

  test "A logged-in user can update metadata", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}

    conn =
      conn
      |> assign(:current_user, @user)
      |> put(book_metadata_path(conn, :update, book_metadata), book_metadata: @valid_attrs)

      assert redirected_to(conn) == book_metadata_path(conn, :index)
      assert get_flash(conn, :info) == "Book updated successfully."
  end

  test "renders form for editing book_metadata", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}

    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_metadata_path(conn, :edit, book_metadata))

    assert conn.status == 200
  end

  test "does not allow a non-logged in user to edit book_metadata", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}

    conn = get conn, book_metadata_path(conn, :edit, book_metadata)

    assert redirected_to(conn) == "/"
  end

  test "the edit page for a book with tags shows the existing tags", %{conn: conn} do

    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    book_metadata = List.first(Repo.all(BookMetadata))

    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_metadata_path(conn, :edit, book_metadata))

    assert html_response(conn, 200) =~ params.tags_list
  end

  test "a list of tags can be updated for a book", %{conn: conn} do
    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    book_metadata = List.first(Repo.all(BookMetadata))
    updated_params = %{title: "The updated book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "good"}

    conn
    |> assign(:current_user, @user)
    |> put(book_metadata_path(conn, :update, book_metadata), book_metadata: updated_params)
    updated_book = List.first(Repo.all(BookMetadata)) |> Repo.preload(:tags)

    assert length(updated_book.tags) == 1
  end

  test "when a book is updated with no tags, all tags are removed for that book", %{conn: conn} do
    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    book_metadata = List.first(Repo.all(BookMetadata))
    updated_params = %{title: "The updated book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: ""}

    conn
    |> assign(:current_user, @user)
    |> put(book_metadata_path(conn, :update, book_metadata), book_metadata: updated_params)

    updated_book = List.first(Repo.all(BookMetadata)) |> Repo.preload(:tags)

    assert length(updated_book.tags) == 0
  end

  test "tags for each book are displayed on the book metadata index page", %{conn: conn} do
    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    conn = get conn, book_metadata_path(conn, :index)

    assert html_response(conn, 200) =~ "nice"
    assert html_response(conn, 200) =~ "short"
    assert html_response(conn, 200) =~ "great"
  end

  test "each tag displayed on the index page is a link to its show page", %{conn: conn} do
    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    conn = get conn, book_metadata_path(conn, :index)
    book = List.first(Repo.all(BookMetadata)) |> Repo.preload(:tags)

    Enum.each(book.tags, fn(tag) ->
      assert html_response(conn, 200) =~ "/tags/#{tag.id}"
    end)
  end

  test "deletes book_metadata", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}

    conn =
      conn
      |> assign(:current_user, @user)
      |> delete(book_metadata_path(conn, :delete, book_metadata))

    assert redirected_to(conn) == book_metadata_path(conn, :index)
    refute Repo.get(BookMetadata, book_metadata.id)
   end

   test "deletes associated books", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}

    conn =
      conn
      |> assign(:current_user, @user)
      |> delete(book_metadata_path(conn, :delete, book_metadata))

    assert redirected_to(conn) == book_metadata_path(conn, :index)
    refute Repo.get(BookMetadata, book_metadata.id)
    refute Repo.get(Book, book.id)
   end

  test "shows the location of each copy", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{} |> Repo.preload(:books)
    location = Repo.insert! %Location{name: "Chicago"}
    Repo.insert! Ecto.build_assoc(book_metadata, :books, location: location)
    conn =
      conn
      |> assign(:curent_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "Chicago"
  end

  test "If a copy is not checked out, shows its location details and a link to check out the book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{} |> Repo.preload(:books)
    Repo.insert! Ecto.build_assoc(book_metadata, :books, current_location: "10th floor")

    conn =
      conn
      |> assign(:curent_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "10th floor"
    assert html_response(conn, 200) =~ "Check out"
  end

  test "given a list of tags, each tag is associated with the book metadata", %{conn: conn} do
    params = %{title: "The book", author_firstname: "first", author_lastname: "last", year: 2016, tags_list: "nice, short, great"}

    conn
    |> assign(:current_user, @user)
    |> post(book_metadata_path(conn, :create), book_metadata: params)

    tag1 = Repo.get_by(Tag, text: "nice") |> Repo.preload(:book_metadata)
    tag2 = Repo.get_by(Tag, text: "short") |> Repo.preload(:book_metadata)
    tag3 = Repo.get_by(Tag, text: "great") |> Repo.preload(:book_metadata)

    assert get_first_book(tag1).title == "The book"
    assert get_first_book(tag2).title == "The book"
    assert get_first_book(tag3).title == "The book"
  end

  test "if a book is checked out, the details page displays the name of the person who has checked out the book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}
    Ecto.build_assoc(book, :check_outs, borrower_name: "Becca")
    |> Repo.insert!

    conn =
      conn
      |> assign(:curent_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "Becca"
  end

  test "if a book is not checked out, index displays a link to check out the book", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    Repo.insert! %Book{book_metadata: book_metadata}

    conn =
      conn
      |> assign(:curent_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "Check out"
  end

  test "if a book is checked out, the div has the class 'checked-out", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    book = Repo.insert! %Book{book_metadata: book_metadata}
    Ecto.build_assoc(book, :check_outs, borrower_name: "Becca")
    |> Repo.insert!

    conn =
      conn
      |> assign(:curent_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "checked-out"
  end

  test "if a book is not checked out, the div has the class 'available'", %{conn: conn} do
    book_metadata = Repo.insert! %BookMetadata{}
    Repo.insert! %Book{book_metadata: book_metadata}

    conn =
      conn
      |> assign(:current_user, @user)
      |> get(book_metadata_path(conn, :show, book_metadata))

    assert html_response(conn, 200) =~ "available"
  end

  defp get_first_book(tag) do
    List.first(tag.book_metadata)
  end
end
