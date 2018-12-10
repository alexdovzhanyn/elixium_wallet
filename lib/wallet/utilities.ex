defmodule ElixiumWallet.Utilities do
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.Graph
  use Scenic.Scene

  def get_from_cache(table, key) do
    with [{id, data}] <-:ets.lookup(table, key) do
      data
    end
  end

  def store_in_cache(table, key, data) do
    :ets.insert(table, {key, data})
  end

  def new_cache_transaction(transaction, amt, true) do
    cache_transaction = %{id: transaction.id, valid?: true, amount: amt, status: "pending"}
    :ets.insert(:transactions, {transaction.id, cache_transaction})
  end

  def new_cache_transaction(:not_enough_balance, amt, true) do
    cache_transaction = %{id: "FAILED", valid?: true, amount: amt, status: "Not Enough Balance"}
    :ets.insert(:transactions, {"FAILED", cache_transaction})
  end

  def new_cache_transaction(:not_enough_balance, amt, :waiting) do
    cache_transaction = %{id: "FAILED", valid?: false, amount: amt, status: "Not Enough Balance"}
    :ets.insert(:transactions, {"FAILED", cache_transaction})
  end

  def new_cache_transaction(:not_enough_balance, amt, false) do
    cache_transaction = %{id: "FAILED", valid?: false, amount: amt, status: "Not Enough Balance"}
    :ets.insert(:transactions, {"FAILED", cache_transaction})
  end



  def new_cache_transaction(transaction, amt, :waiting) do
    cache_transaction = %{id: transaction.id, valid?: false, amount: amt, status: "awaiting Gossip"}
    :ets.insert(:transactions, {transaction.id, cache_transaction})
  end

  def new_cache_transaction(transaction, amt, false) do
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
    [add] = graph.ids[:addr_valid]
    primitives = graph.primitives
    to_insert = primitives[id] |> Map.put(:data, {Scenic.Component.Input.TextField, value})
    primitives_to_insert = Map.put(primitives, id, to_insert)

    second = primitives_to_insert[add] |> Map.put(:styles, %{fill: {121, 101, 179}})
    insert = Map.put(primitives_to_insert, add, second)

    graph_complete = Map.put(graph, :primitives, insert)

    Map.put(state, :graph, graph)
  end



end
