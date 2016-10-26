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

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case User.find_or_create(auth) do
      {:ok, user} ->
        path = get_session(conn, :redirect_url) || "/"
        conn
        |> put_flash(:info, "Authentication successful.")
        |> put_session(:current_user, user)
        |> redirect(to: path)
    end
  end
end

