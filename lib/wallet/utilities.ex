defmodule ElixWallet.Utilities do

  def get_from_cache(table, key) do
    with [{id, data}] <-:ets.lookup(table, key) do
      data
    end
  end

  def store_in_cache(table, key, data) do
    :ets.insert(table, {key, data})
  end
end
