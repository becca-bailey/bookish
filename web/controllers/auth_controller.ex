defmodule Bookish.AuthController do
  use Bookish.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Bookish.User

  def request(conn, _params) do
    IO.inspect Helpers.callback_url(conn)
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    User.find_or_create(auth)
    conn
    |> put_flash(:info, "Authenticated")
    |> redirect(to: "/")
  end
end

