defmodule Gig.Store do
  @moduledoc """
  Implements a in-memory key value store with queryable
  timestamps (so that keys can be extended or expired).
  """
  def create_table(name) do
    ^name = :ets.new(name, [:public,
                            :named_table,
                            read_concurrency: true])
  end

  def query(table, spec) do
    :ets.select(table, [spec])
  end

  def all(table) do
    spec = {{:"_", :"_", :"$1"}, [], [:"$1"]}
    query(table, spec)
  end

  def earlier_than(table, unix_timestamp) do
    spec = {{:"_", :"$1", :"$2"},
            [{:"=<", :"$1", {:const, unix_timestamp}}],
            [:"$2"]}
    query(table, spec)
  end

  def later_than(table, unix_timestamp) do
    spec = {{:"_", :"$1", :"$2"},
            [{:">", :"$1", {:const, unix_timestamp}}],
            [:"$2"]}
    query(table, spec)
  end

  def find(table, id) do
    case :ets.lookup(table, id) do
      [{^id, _timestamp, obj}] -> {:ok, obj}
      [] -> {:error, :not_found}
    end
  end

  def find_many(table, ids) do
    specs = Enum.map(ids, fn(id) ->
      {{id, :"_", :"$1"}, [], [:"$1"]}
    end)
    :ets.select(table, specs)
  end

  def extend(table, id) do
    :ets.update_element(table, id, {2, get_now()})
  end

  def save(table, objs) when is_list(objs) do
    now = get_now()
    inserts = Enum.map(objs, fn(e) -> {e.id, now, e} end)
    :ets.insert(table, inserts)
  end
  def save(table, obj) do
    :ets.insert(table, {obj.id, get_now(), obj})
  end

  def save(table, obj, key) do
    :ets.insert(table, {key, get_now(), obj})
  end

  def clear(table) do
    :ets.delete_all_objects(table)
  end

  def get_now do
    DateTime.utc_now
    |> DateTime.to_unix(:millisecond)
  end
end
