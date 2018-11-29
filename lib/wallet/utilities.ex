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
    id = graph.ids.id |> IO.inspect

    #Map.get_and_update(graph, :primitives, fn current_value ->
    #  {current_value, primitives}
    #end)
    #primitives = graph.primitives
    #to_insert = primitives[4] |> Map.put(:data, {Scenic.Component.Input.TextField, value})
    #primitives_to_insert = Map.put(primitives, 4, to_insert)
    #graph_complete = Map.put(graph, :primitives, primitives_to_insert)
    #state_to_send = Map.put(state, :graph, graph_complete)

  end
end
