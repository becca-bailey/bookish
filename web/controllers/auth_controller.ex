defmodule Bookish.AuthController do
  use Bookish.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Bookish.User

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, params) do
    IO.puts "Authentication failed"
    IO.inspect fails
    IO.inspect params
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    IO.puts "Authentication succeeded for #{auth.info.name}"
    IO.inspect params
    case User.find_or_create(auth) do
      {:ok, user} ->
        path = get_path(conn)
        conn
        |> put_flash(:info, "Authentication successful.")
        |> put_session(:current_user, user)
        |> redirect(to: path)
    end
  end

  def get_user(conn) do
    get_session(conn, :current_user) || conn.assigns[:current_user]
  end

  defp get_path(conn) do
    if get_session(conn, :redirect_method) in ["POST", "PUT", "DELETE"] do
      "/books"
    else
      get_session(conn, :redirect_url) || "/"
    end
  end
end

