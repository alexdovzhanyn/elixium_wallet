defmodule ElixWallet.Utilities do

  def get_from_cache(table, key) do
    with [{id, data}] <-:ets.lookup(table, key) do
      data
    end
  end

  def store_in_cache(table, key, data) do
    :ets.insert(table, {key, data})
  end

  def update_internal_state({event, id, value}, state) do
    graph = state.graph
    [id] = graph.ids[id] |> IO.inspect
    primitives = graph.primitives
    to_insert = primitives[id] |> Map.put(:data, {Scenic.Component.Input.TextField, value})
    primitives_to_insert = Map.put(primitives, id, to_insert)
    graph_complete = Map.put(graph, :primitives, primitives_to_insert)
    Map.put(state, :graph, graph_complete) |> IO.inspect
  end
end
