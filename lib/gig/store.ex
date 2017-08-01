defmodule Gig.Store do
  def create_table(name) do
    ^name = :ets.new(name, [:public,
                            :named_table,
                            read_concurrency: true])
  end

  def all(table) do
    spec = {{:"_", :"$1"}, [], [:"$1"]}
    :ets.select(table, [spec])
  end

  def save(table, objs) when is_list(objs) do
    inserts = Enum.map(objs, fn(e) -> {e.id, e} end)
    :ets.insert(table, inserts)
  end
  def save(table, obj) do
    :ets.insert(table, {obj.id, obj})
  end
end
