defmodule ElixWallet.Network.Helpers do

  def setup() do
    :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
    :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
    :ets.insert(:scenic_cache_key_table, {"latency", 1, {0.0, 0.0, 0.0}})
    :ets.insert(:scenic_cache_key_table, {"block_info", 1, {0, 0.0}})
  end


  def get_stats() do
    connected_peers = Elixium.P2P.Peer.connected_handlers
    registered_peers = Elixium.P2P.Peer.fetch_peers_from_registry(31013)

    ping_times = connected_peers |> Enum.map(fn peer -> get_ping_time(peer) end)
    store_latency(ping_times)
    case registered_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, Enum.count(registered_peers)})
    end
    case connected_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, Enum.count(connected_peers)})
    end
  end

  defp store_latency(times) do
    raw_times = times |> Enum.map(fn{status, {node, time}} -> time end)
    min_ping = Enum.min(raw_times)
    max_ping = Enum.max(raw_times)
    avg_ping = Enum.sum(raw_times) / Enum.count(raw_times)
    :ets.insert(:scenic_cache_key_table, {"latency", 1, {avg_ping, min_ping, max_ping}})
  end

  defp get_block_info() do
    last_block = Elixium.Store.Ledger.last_block()
    difficulty = last_block.difficulty*1.0
    index = last_block.index
    :ets.insert(:scenic_cache_key_table, {"block_info", 1, {index, difficulty}})
  end

  def get_ping_time(pid) do
    start = :erlang.timestamp()
    with :pang <- :net_adm.ping(:erlang.node(pid)) do
      ping = :timer.now_diff(:erlang.timestamp(), start)
      {:ok, {:erlang.node(pid), ping/1000}}
    else
      false ->
        ping = :timer.now_diff(:erlang.timestamp(), start)
      {:error, {node(pid), ping/1000}}
    end
  end

end
