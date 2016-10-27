defmodule Bookish.User do
  use Bookish.Web, :model

  alias Ueberauth.Auth

  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: auth.info.name}
  end
end
