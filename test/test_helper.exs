ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Bookish.Repo, :manual)

defmodule Bookish.TestHelpers do

  def empty?(coll) do
    is_nil(List.first(coll))
  end

end
