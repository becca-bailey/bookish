defmodule Bookish.Resource do
  use Bookish.Web, :model

  def paginate(query, page, size) do
    from b in query,
      limit: ^size,
      offset: ^((page-1) * size)
  end

  def count(query) do
    from b in query,
      select: count(b.id)
  end
end
