defmodule Bookish.Plugs.RequireAuth do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do
    case current_user?(conn) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> put_session(:redirect_method, conn.method)
        |> Phoenix.Controller.put_flash(:info, "Please log in to continue.")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt
      _ ->
        conn
    end
  end

  defp current_user?(conn) do
    get_session(conn, :current_user) || conn.assigns[:current_user]
  end

end
