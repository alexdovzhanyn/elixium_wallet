defmodule ElixiumWallet.Utilities do

  def get_from_cache(table, key) do
    with [{id, data}] <-:ets.lookup(table, key) do
      data
    end
  end

  def store_in_cache(table, key, data) do
    :ets.insert(table, {key, data})
  end

  def new_cache_transaction(transaction, amt, true) do
    IO.puts "Working true"
    cache_transaction = %{id: transaction.id, valid?: true, amount: amt, status: "pending"}
    :ets.insert(:transactions, {transaction.id, cache_transaction})
  end

  def new_cache_transaction(transaction, amt, :waiting) do
    IO.puts "Working pending"
    cache_transaction = %{id: transaction.id, valid?: false, amount: amt, status: "awaiting Gossip"}
    :ets.insert(:transactions, {transaction.id, cache_transaction})
  end

  def new_cache_transaction(transaction, amt, false) do
    IO.puts "Working false"
    cache_transaction = %{id: transaction.id, valid?: false, amount: amt, status: "invalid"}
    :ets.insert(:transactions, {transaction.id, cache_transaction})
  end

  def update_cache_transaction(id, transaction, amt, :confirmed) do
    cache_transaction = %{id: transaction.id, valid?: true, amount: amt, status: "Confirmed"}
    :ets.update_element(:transactions, id, {2, cache_transaction})
  end

  def update_cache_transaction(id, transaction, amt, :error) do
    cache_transaction = %{id: transaction.id, valid?: true, amount: amt, status: "invalid"}
    :ets.update_element(:transactions, id, {2, cache_transaction})
  end

  def get_single_transaction(id) do
    :ets.match_object(:transactions,  {id, :"_"})
  end

  def get_cache_transactions() do
    :ets.match_object(:transactions,  {:"_", :"_"})
  end

  def update_internal_state({event, id, value}, state) do
    graph = state.graph
    [id] = graph.ids[id]
    primitives = graph.primitives
    to_insert = primitives[id] |> Map.put(:data, {Scenic.Component.Input.TextField, value})
    primitives_to_insert = Map.put(primitives, id, to_insert)
    graph_complete = Map.put(graph, :primitives, primitives_to_insert)
    Map.put(state, :graph, graph_complete)
  end

  def update_internal_state({:value_changed, :fee, value}, state, :dropdown) do

    graph = state.graph
    [id] = graph.ids[:fee]
    primitives = graph.primitives
    to_insert = primitives[id] |> Map.put(:data, {Scenic.Component.Input.DropDown, value})
    primitives_to_insert = Map.put(primitives, id, to_insert)
    graph_complete = Map.put(graph, :primitives, primitives_to_insert)
    Map.put(state, :graph, graph_complete)
  end


end
